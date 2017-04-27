describe "jsonReceiver adapter", type: :request do
  before { unstub_ethereum_calls }

  let(:coordinator) { factory_create :coordinator }
  let(:coordinator_headers) { coordinator_log_in(coordinator, {"Content-Type" => "application/json"}) }
  let(:endpoint) { "https://example.com/api/data" }
  let(:original_value) { "1006.14" }
  let(:updated_value) { "1007.15" }
  let(:first_time) { 1.day.from_now }
  let(:second_time) { 2.days.from_now }
  let(:key) { SecureRandom.base64 }
  let(:oracle_address) { ethereum_address }
  let(:oracle_method) { SecureRandom.hex(4) }
  let(:assignment_params) do
    assignment_1_0_0_json({
      skipInitialSnapshot: true,
      input_params:     {
        fields: [key],
        url: endpoint, }, input_type: 'jsonReceiver',
      output_params: {
        address: oracle_address,
        method: oracle_method
      },
      output_type: 'ethereumBytes32',
      schedule: {
        runAt: [first_time, second_time].map(&:to_i).map(&:to_s)
      },
    })
  end
  let(:value) { 'abc' }

  it "receives requests which trigger new assignments" do
    expect {
      post '/assignments/', assignment_params, coordinator_headers
    }.to change {
      coordinator.assignments.count
    }.by(+1)
    assignment = Assignment.find_by xid: response_json['xid']

    receiver = assignment.adapters.first
    expect {
      post "/json_receivers/#{receiver.xid}/requests", {key => value}
    }.to change {
      receiver.requests.count
    }.by(+1)

    expect_any_instance_of(Ethereum::Client).to receive(:send_raw_transaction) do |client, hex|
      tx = Eth::Tx.decode hex
      hex_data = bin_to_hex tx.data
      expect(hex_data).to match(/\A#{oracle_method}/)
      hex_payload = hex_data.gsub(/\A#{oracle_method}/, '')

      expect(ethereum.hex_to_utf8 hex_payload).to eq(value)
    end

    run_delayed_jobs
  end
end
