describe Ethereum::ConfirmationWatcher, type: :model do
  describe "#perform" do
    let!(:tx) { factory_create(:ethereum_transaction, confirmations: 0) }
    let(:watcher) { Ethereum::ConfirmationWatcher.new tx }
    let(:response) { ethereum_receipt_response(block_number: block_number).result }

    before do
      allow_any_instance_of(Ethereum::Client).to receive(:get_transaction_receipt)
        .with(tx.txid)
        .and_return(response)
    end

    context "when the transaction is NOT confirmed" do
      let(:block_number) { nil }

      it "does NOT mark the transaction as confirmed" do
        expect {
          watcher.perform
        }.not_to change {
          tx.reload.confirmed?
        }.from(false)
      end

      it "does rebroadcast the transaction" do
        expect_any_instance_of(Ethereum::Client).to receive(:send_raw_transaction)
          .with(tx.raw_hex)

        watcher.perform
      end
    end

    context "when the transaction is confirmed" do
      let(:block_number) { "0x7517" }

      it "does mark the transaction as confirmed" do
        expect {
          watcher.perform
        }.to change {
          tx.reload.confirmed?
        }.from(false).to(true)
      end

      it "does NOT rebroadcast the transaction" do
        expect_any_instance_of(Ethereum::Client).not_to receive(:send_raw_transaction)

        watcher.perform
      end
    end
  end
end
