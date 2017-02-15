describe Ethereum::LogSubscription do

  describe "validations" do
    it { is_expected.to have_valid(:account).when(ethereum_address) }
    it { is_expected.not_to have_valid(:account).when(nil) }

    it { is_expected.to have_valid(:end_at).when(Time.now) }
    it { is_expected.not_to have_valid(:end_at).when(nil) }

    it { is_expected.to have_valid(:owner).when(factory_create :ethereum_contract) }
    it { is_expected.not_to have_valid(:owner).when(nil) }
  end

  describe "on create" do
    let(:account) { ethereum_address }
    let(:end_at) { Time.now }
    let(:xid) { SecureRandom.uuid }
    let(:subscription) { Ethereum::LogSubscription.new account: account, end_at: end_at }

    it "creates a remote log subscription and saves its identifier" do
      allow_any_instance_of(WeiWatchersClient).to receive(:create_subscription)
        .with({
          account: account,
          end_at: end_at,
        })
        .and_return({'xid' => xid})

      expect {
        subscription.save
      }.to change {
        subscription.xid
      }.from(nil).to(xid)
    end
  end

  describe "#log" do
    let(:event) { factory_create :ethereum_event }
    let(:subscription) { factory_create :ethereum_log_subscription }

    it "sends the event to the subscription owner" do
      expect(subscription.owner).to receive(:event_logged)
        .with(event)

      subscription.log event
    end
  end
end
