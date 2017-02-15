describe WeiWatchers::EventsController, type: :controller do

  describe "#create" do
    let(:subscription) { factory_create :ethereum_log_subscription }
    let(:log_event_params) do
      {
        address: ethereum_address,
        blockHash: ethereum_txid,
        blockNumber: 341231,
        data: SecureRandom.hex,
        logIndex: 5,
        subscription: subscription.xid,
        topics: [ethereum_txid],
        transactionHash: ethereum_txid,
        transactionIndex: 2,
      }
    end

    it "creates a new log event for the associated subscription" do
      expect {
        post :create, log_event_params
      }.to change {
        Ethereum::Event.count
      }.by(+1)
    end
  end

end
