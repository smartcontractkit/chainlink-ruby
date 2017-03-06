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

end
