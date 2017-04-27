describe "Ethereum oracle with an preformatted arbitrary data type", type: :request do
  before { unstub_ethereum_calls }

  let(:coordinator) { factory_create :coordinator }
  let(:coordinator_headers) { coordinator_log_in(coordinator, {"Content-Type" => "application/json"}) }
  let(:endpoint) { "https://example.com/api/data" }
  let(:api_value) { SecureRandom.hex(64) }
  let(:assignment_params) do
    assignment_1_0_0_json({
      input_params: {
        fields: ['last'],
        url: endpoint,
      }.compact,
      input_type: 'httpGetJSON',
      output_params: output_params,
      output_type: Ethereum::FormattedOracle::SCHEMA_NAME,
    })
  end
  let(:oracle_address) { ethereum_address }
  let(:oracle_method) { SecureRandom.hex(4) }
  let(:output_params) do
    {
      address: oracle_address,
      method: oracle_method
    }
  end

  before do
    allow(HttpRetriever).to receive(:get)
      .with(endpoint, {})
      .and_return({last: api_value}.to_json)

    allow_any_instance_of(Ethereum::Client).to receive(:send_raw_transaction)
  end

  it "does not create a new contract" do
    expect {
      post '/assignments/', assignment_params, coordinator_headers
    }.to change {
      coordinator.assignments.count
    }.by(+1)
    run_delayed_jobs
    assignment = Assignment.find_by xid: response_json['xid']
    oracle = assignment.adapters.last
    expect(oracle.ethereum_contract).to be_nil

    expect_any_instance_of(Ethereum::Client).to receive(:send_raw_transaction) do |client, hex|
      tx = Eth::Tx.decode hex
      hex_data = bin_to_hex tx.data
      expect(hex_data).to match(/\A#{oracle_method}/)
      hex_payload = hex_data.gsub(/\A#{oracle_method}/, '')
      expect(hex_payload).to eq(api_value)
    end

    wait_for_ethereum_confirmation oracle.writes.last.txid
    run_ethereum_confirmation_watcher
    run_delayed_jobs
  end
end
