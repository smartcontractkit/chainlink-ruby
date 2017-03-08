describe "watching already deployed addresses", type: :request do
  before { unstub_ethereum_calls }

  let(:coordinator) { factory_create :coordinator }
  let(:coordinator_headers) { coordinator_log_in(coordinator, {"Content-Type" => "application/json"}) }
  let(:endpoint) { "https://example.com/api/data" }
  let(:deadline) { 1.year.from_now.to_i.to_s }
  let(:assignment_type) { assignment_types(:basic) }
  let(:assignment_params) do
    assignment_1_0_0_json({
      endAt: deadline,
      input_params: {
        address: watched_address,
      },
      input_type: 'ethereumLogWatcher',
      output_params: {},
      output_type: assignment_type.name,
    })
  end
  let(:event_txid) { ethereum_txid }
  let(:event_parameters) do
    {
      address: ethereum_address,
      blockHash: ethereum_txid,
      blockNumber: rand(1_000_000),
      data: SecureRandom.hex(32),
      logIndex: rand(1_000),
      transactionHash: event_txid,
      transactionIndex: rand(1_000),
    }
  end
  let(:event_details) { event_hash subscription: subscription.xid }
  let(:watched_address) { ethereum_address }

  it "subscribes to logs of the watched address and passes the log on to the next adapter" do
    expect {
      post '/assignments/', assignment_params, coordinator_headers
    }.to change {
      coordinator.assignments.count
    }.by(+1)
    assignment = Assignment.last
    log_watcher = assignment.adapters.first
    subtask2 = assignment.subtasks.second

    expect(WeiWatchersClient).to receive(:post) do |path, params|
      expect(path).to eq('/subscriptions')
      expect(params).to eq(body: {
        account: watched_address,
        endAt: deadline,
      })

      http_response(body: {
        end_at: deadline,
        xid: SecureRandom.uuid,
      }.to_json)
    end
    run_delayed_jobs

    log_subscription = log_watcher.log_subscriptions.first
    expect {
      post '/wei_watchers/events', event_parameters.merge({
        subscription: log_subscription.xid
      })
    }.to change {
      log_subscription.reload.events.count
    }.by(+1)


    expect(ExternalAdapterClient).to receive(:post) do |url, params|
      adapter_url = assignment_type.external_adapter.url
      expect(url).to eq("#{adapter_url}/assignments/#{subtask2.xid}/snapshots")

      expect(params[:body][:details]['txid']).to eq(event_txid)

      http_response
    end

    run_delayed_jobs
  end
end
