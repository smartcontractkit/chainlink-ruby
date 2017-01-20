describe "assignment with a schema version 1.0.0", type: :request do
  before { unstub_ethereum_calls }

  let(:coordinator_url) { "https://example.com/api/coordinator" }
  let(:coordinator) { factory_create :coordinator, url: coordinator_url }
  let(:headers) { coordinator_log_in(coordinator, {"Content-Type" => "application/json"}) }
  let(:endpoint) { "https://example.com/api/data" }
  let(:oracle_value) { "790.28" }
  let(:input_type) { 'httpGetJSON' }
  let(:input_params) do
    {
      url: endpoint,
      fields: ['last']
    }
  end
  let(:assignment_params) do
    assignment_1_0_0_json({
      input_params: input_params,
      input_type: input_type,
      output_params: output_params,
      output_type: output_type,
    })
  end

  before do
    allow(HttpRetriever).to receive(:get)
      .with(endpoint)
      .and_return({last: oracle_value}.to_json)
  end

  context "when the address and method are NOT specified" do
    let(:output_type) { 'ethereumBytes32' }
    let(:output_params) { {} }

    it "creates an oracle and updates it on schedule until the deadline is passed" do
      expect {
        post '/assignments/', assignment_params, headers
      }.to change {
        coordinator.assignments.count
      }.by(+1)
      assignment = Assignment.find_by xid: response_json['xid']
      oracle = assignment.adapters.last
      contract = oracle.ethereum_contract
      genesis_txid = contract.genesis_transaction.txid
      wait_for_ethereum_confirmation genesis_txid

      expect(CoordinatorClient).to receive(:post)
        .with("#{coordinator_url}/assignments/#{assignment.xid}", instance_of(Hash))
        .and_return(acknowledged_response)

      expect {
        run_ethereum_contract_confirmer
      }.to change {
        contract.reload.address
      }.from(nil)

      expect {
        wait_for_ethereum_confirmation oracle.writes.last.txid
      }.to change {
        get_oracle_value oracle
      }.from('').to(oracle_value)

      expect(CoordinatorClient).to receive(:post)
        .with("#{coordinator_url}/snapshots", instance_of(Hash))
        .and_return(acknowledged_response)
      run_delayed_jobs
    end
  end

  context "when the address and method are specified" do
    let(:output_type) { 'ethereumBytes32' }
    let(:oracle_address) { ethereum_address }
    let(:oracle_method) { SecureRandom.hex(4) }
    let(:output_params) do
      {
        address: oracle_address,
        method: oracle_method
      }
    end

    before do
      allow_any_instance_of(Ethereum::Client).to receive(:send_raw_transaction)
    end

    it "does not create a new contract" do
      expect(CoordinatorClient).not_to receive(:post)
        .with("#{coordinator_url}/oracles", instance_of(Hash))

      expect {
        post '/assignments/', assignment_params, headers
      }.to change {
        coordinator.assignments.count
      }.by(+1)
      assignment = Assignment.find_by xid: response_json['xid']
      oracle = assignment.adapters.last
      expect(oracle.ethereum_contract).to be_nil

      expect_any_instance_of(Ethereum::Client).to receive(:send_raw_transaction) do |client, hex|
        tx = Eth::Tx.decode hex
        hex_data = bin_to_hex tx.data
        expect(hex_data).to match(/\A#{oracle_method}/)
        hex_payload = hex_data.gsub(/\A#{oracle_method}/, '')
        expect(ethereum.hex_to_utf8 hex_payload).to eq(oracle_value)
      end
      expect(CoordinatorClient).to receive(:post)
        .with("#{coordinator_url}/snapshots", instance_of(Hash))
        .and_return(acknowledged_response)

      wait_for_ethereum_confirmation oracle.writes.last.txid
      run_ethereum_confirmation_watcher
      run_delayed_jobs
    end
  end
end
