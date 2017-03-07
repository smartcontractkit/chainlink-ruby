describe Ethereum::LogWatcher do

  describe "validations" do
    it { is_expected.to have_valid(:address).when(ethereum_address) }
    it { is_expected.not_to have_valid(:address).when(nil, '') }
  end

  describe "on create" do
    let(:subtask) { factory_build :subtask, adapter: nil }
    let(:watcher) { factory_build :ethereum_log_watcher, subtask: subtask }

    it "pulls the address from the body" do
      expect {
        watcher.save
      }.to change {
        watcher.address
      }.from(nil)
    end

    it "generates a WeiWatchers log subscription" do
      expect {
        run_generated_jobs { watcher.save }
        watcher.reload
      }.to change {
        watcher.log_subscriptions.size
      }.from(0).to(1)

      subscription = watcher.log_subscriptions.last
      expect(subscription.account).to eq(watcher.address)
      expect(subscription.end_at).to eq(watcher.end_at)
    end
  end

  describe "#event_logged" do
    let(:event) { factory_create :ethereum_event }
    let(:subtask) { factory_build :subtask, adapter: nil }
    let(:watcher) { factory_create :ethereum_log_watcher, subtask: subtask }
    let(:assignment) { watcher.assignment }

    it "creates a new event" do
      expect {
        watcher.event_logged event
      }.to change {
        assignment.snapshots.count
      }.by(+1)

      snapshot = assignment.snapshots.last
      expect(snapshot.request).to eq(event)
      expect(snapshot.requester).to eq(subtask)
    end
  end

  describe "#get_status" do
    let(:subtask) { factory_build :subtask, adapter: nil }
    let!(:watcher) { factory_create :ethereum_log_watcher, subtask: subtask }
    let(:assignment) { subtask.assignment }
    let(:assignment_snapshot) { factory_create :assignment_snapshot, assignment: assignment }
    let(:snapshot) { factory_create :adapter_snapshot, assignment_snapshot: assignment_snapshot }
    let(:previous_snapshot) { factory_create :adapter_snapshot }

    context "when the subtask is NOT the requester" do
      context "when there was a previous snapshot" do
        it "returns the snapshot that was sent to it" do
          result = watcher.get_status snapshot, previous_snapshot

          expect(result).to eq(previous_snapshot)
        end
      end

      context "when there was no previous snapshot" do
        it "a null snapshot" do
          result = watcher.get_status snapshot, nil

          expect(result.status).to be_nil
          expect(result.description).to be_nil
          expect(result.description_url).to be_nil
          expect(result.details).to be_nil
          expect(result.value).to be_nil
          expect(result.config).to be_nil
          expect(result.errors).to be_empty
          expect(result.fulfilled).to be true
        end
      end
    end

    context "when the subtask is the requester" do
      let(:event) { factory_create :ethereum_event }
      let(:assignment_snapshot) do factory_create(:assignment_snapshot, {
          assignment: assignment,
          request: event,
          requester: subtask,
        })
      end
      it "returns a snapshot containing the request data" do
        result = watcher.get_status snapshot, previous_snapshot

        expect(result.summary).to eq("Event logged.")
        expect(result.description).to eq("Event: #{event.transaction_hash}##{event.log_index}")
        expect(result.description_url).to eq(Ethereum::Client.tx_url event.transaction_hash)
        expect(result.details).to be_present
        expect(result.value).to eq event.data
        expect(result.errors).to be_empty
        expect(result.fulfilled).to be true
        expect(result.status).to be_nil
      end
    end
  end

end
