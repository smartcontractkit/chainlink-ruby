describe "assignment creation and performance", type: :request do
  before { unstub_ethereum_calls }

  let(:coordinator_url) { "https://example.com/api/coordinator" }
  let(:coordinator) { factory_create :coordinator, url: coordinator_url }
  let(:headers) { coordinator_log_in(coordinator, {"Content-Type" => "application/json"}) }
  let(:endpoint) { "https://example.com/api/data" }
  let(:oracle_value) { "790.28" }
  let(:adapter_params) do
    {
      endpoint: endpoint,
      fields: ['last']
    }
  end
  let(:adapter_type) { EthereumOracle::SCHEMA_NAME }
  let(:assignment_params) do
    assignment_0_1_0_json({
      adapterParams: adapter_params,
      adapterType: adapter_type
    })
  end

  before do
    allow(HttpRetriever).to receive(:get)
      .with(endpoint)
      .and_return({last: oracle_value}.to_json)
  end

  it "creates an oracle and updates it on schedule until the deadline is passed" do
    expect {
      post '/assignments/', assignment_params, headers
    }.to change {
      coordinator.assignments.count
    }.by(+1)
    assignment = Assignment.find_by xid: response_json['xid']
    oracle = assignment.adapters.first
    contract = oracle.ethereum_contract
    genesis_txid = contract.genesis_transaction.txid
    wait_for_ethereum_confirmation genesis_txid

    expect {
      run_ethereum_contract_confirmer
    }.to change {
      contract.reload.address
    }.from(nil)

    expect(CoordinatorClient).to receive(:post)
      .with("#{coordinator_url}/oracles", instance_of(Hash))
      .and_return(acknowledged_response)
    expect(CoordinatorClient).to receive(:post)
      .with("#{coordinator_url}/snapshots", instance_of(Hash))
      .and_return(acknowledged_response)

    expect {
      run_delayed_jobs
      wait_for_ethereum_confirmation oracle.writes.last.txid
    }.to change {
      get_oracle_value oracle
    }.from('').to(oracle_value)
  end
end
