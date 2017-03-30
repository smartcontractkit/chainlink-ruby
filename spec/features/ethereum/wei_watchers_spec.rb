describe "integration with WeiWatchers", type: :request do
  before { unstub_ethereum_calls }

  let(:coordinator) { factory_create :coordinator }
  let(:coordinator_headers) { coordinator_log_in(coordinator, {"Content-Type" => "application/json"}) }
  let(:endpoint) { "https://example.com/api/data" }
  let(:first_value) { 1048 }
  let(:second_value) { 1049 }
  let(:output_type) { Ethereum::Int256Oracle::SCHEMA_NAME }
  let(:deadline) { 1.year.from_now.to_i.to_s }
  let(:assignment_params) do
    assignment_1_0_0_json({
      input_params: {
        fields: ['last'],
        url: endpoint,
      },
      schedule: {
        runAt: [deadline],
      },
      input_type: 'httpGetJSON',
      output_params: {},
      output_type: output_type,
    })
  end
  let(:event_details) { event_hash subscription: subscription.xid }

  before do
    EthereumContractTemplate.for(output_type).update_attributes use_logs: true

    allow(HttpRetriever).to receive(:get)
      .with(endpoint, instance_of(Hash))
      .and_return({last: first_value}.to_json)
  end

  it "creates an oracle and updates it on schedule until the deadline is passed" do
    expect {
      post '/assignments/', assignment_params, coordinator_headers
    }.to change {
      coordinator.assignments.count
    }.by(+1)
    assignment = Assignment.find_by xid: response_json['xid']
    oracle = assignment.adapters.last

    expect(WeiWatchersClient).to receive(:post) do |path, params|
      expect(path).to eq('/subscriptions')
      expect(params).to eq({
        basic_auth: wei_watchers_credentials,
        body: {
          account: oracle.reload.contract_address,
          endAt: deadline,
        },
      })

      http_response(body: {
        end_at: deadline,
        xid: SecureRandom.uuid,
      }.to_json)
    end

    wait_for_ethereum_confirmation oracle.ethereum_contract.genesis_transaction.txid
    run_ethereum_contract_confirmer
    wait_for_ethereum_confirmation oracle.writes.last.txid
    run_delayed_jobs
    contract = oracle.ethereum_contract
    subscription = contract.reload.log_subscriptions.last
    expect(subscription).to be_present

    allow(HttpRetriever).to receive(:get)
      .with(endpoint, instance_of(Hash))
      .and_return({last: second_value}.to_json)

    event_details = event_hash subscription: subscription.xid
    expect {
      post '/wei_watchers/events', event_details
    }.to change {
      subscription.reload.events.count
    }.by(+1)

    expect {
      run_delayed_jobs
    }.to change {
      oracle.reload.writes.count
    }.by(+1)
    wait_for_ethereum_confirmation oracle.writes.last.txid

    expect(get_oracle_uint oracle).to eq(second_value)
  end
end
