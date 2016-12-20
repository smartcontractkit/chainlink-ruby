describe Ethereum::BalanceWatcher, type: :model do

  describe "#perform" do
    let(:address) { ENV['ETHEREUM_ACCOUNT'] }
    let(:mail) { double Notification }

    before do
      allow_any_instance_of(Ethereum::Client).to receive(:account_balance)
        .and_return(balance)
    end

    context "when the balance is above the threshhold" do
      let(:balance) { ENV['ETHEREUM_MINIMUM_BALANCE'].to_i + 1 }

      it "does NOT send a notification" do
        expect(Notification).not_to receive(:ethereum_balance)

        Ethereum::BalanceWatcher.perform
      end
    end

    context "when the balance is below the threshhold" do
      let(:balance) { ENV['ETHEREUM_MINIMUM_BALANCE'].to_i }

      it "does send a notification" do
        expect(Notification).to receive(:ethereum_balance)
          .with(address, balance)
          .and_return(mail)
        expect(mail).to receive(:deliver_now)

        Ethereum::BalanceWatcher.perform
      end
    end
  end

end
