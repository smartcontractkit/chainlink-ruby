describe "assignment with a schema version 1.0.0", type: :request do
  before { unstub_ethereum_calls }

  let(:coordinator) { factory_create :coordinator }
  let(:coordinator_headers) { coordinator_log_in(coordinator, {"Content-Type" => "application/json"}) }
  let(:endpoint) { "https://example.com/api/data" }
  let(:original_value) { "1006.14" }
  let(:updated_value) { "1007.15" }
  let(:first_time) { 1.day.from_now }
  let(:second_time) { 2.days.from_now }
  let(:assignment_params) do
    assignment_1_0_0_json({
      input_params:     {
        fields: ['last'],
        url: endpoint,
      },
      input_type: 'httpGetJSON',
      output_params: {},
      output_type: 'ethereumBytes32',
      schedule: {
        runAt: [first_time, second_time].map(&:to_i).map(&:to_s)
      },
    })
  end

  it "creates an oracle and updates it on schedule until the deadline is passed" do
    allow(HttpRetriever).to receive(:get)
      .and_return({last: original_value}.to_json)

    expect {
      post '/assignments/', assignment_params, coordinator_headers
    }.to change {
      coordinator.assignments.count
    }.by(+1)
    assignment = Assignment.find_by xid: response_json['xid']
    oracle = assignment.adapters.last
    contract = oracle.ethereum_contract
    genesis_txid = contract.genesis_transaction.txid
    wait_for_ethereum_confirmation genesis_txid

    expect {
      run_ethereum_contract_confirmer
    }.to change {
      contract.reload.address
    }.from(nil)

    wait_for_ethereum_confirmation oracle.reload.writes.first.txid


    allow(HttpRetriever).to receive(:get)
      .and_return({last: updated_value}.to_json)

    Timecop.freeze(first_time - 61.seconds) do
      expect {
        run_scheduled_assignments
      }.not_to change {
        Delayed::Job.count
      }
    end

    Timecop.freeze(first_time - 60.seconds) do
      expect {
        run_scheduled_assignments
      }.to change {
        Delayed::Job.count
      }
    end

    Timecop.freeze(first_time - 1.second) do
      expect {
        run_delayed_jobs
        wait_for_ethereum_confirmation oracle.reload.writes.last.txid
      }.not_to change {
        get_oracle_utf8 oracle
      }.from(original_value)
    end

    Timecop.freeze(first_time) do
      expect {
        run_delayed_jobs
        wait_for_ethereum_confirmation oracle.reload.writes.last.txid
      }.to change {
        get_oracle_utf8 oracle
      }.from(original_value).to(updated_value)
    end
  end
end
