describe EthereumTransaction, type: :model do

  describe "validations" do
    it { is_expected.to have_valid(:account).when(Ethereum::Account.new) }
    it { is_expected.not_to have_valid(:account).when(nil) }

    it { is_expected.to have_valid(:txid).when("0x#{SecureRandom.hex(32)}") }
    it { is_expected.not_to have_valid(:txid).when(nil, '', "0x", SecureRandom.hex(32), "0x#{SecureRandom.hex(20)}") }
  end

  describe ".unconfirmed" do
    subject { EthereumTransaction.unconfirmed }

    let(:confirmed1) { factory_create :ethereum_transaction, confirmations: 1 }
    let(:confirmed2) { factory_create :ethereum_transaction, confirmations: 2 }
    let(:unconfirmed1) { factory_create :ethereum_transaction, confirmations: 0 }
    let(:unconfirmed2) { factory_create :ethereum_transaction, confirmations: nil }

    it { is_expected.not_to include confirmed1 }
    it { is_expected.not_to include confirmed2 }
    it { is_expected.to include unconfirmed1 }
    it { is_expected.to include unconfirmed2 }
  end

  describe "#unconfirmed_update!" do
    let(:tx) { factory_create :ethereum_transaction, confirmations: confirmations }
    let(:confirmations) { 0 }
    let(:new_price) { 100_000 }

    it "updates the attributes passed in" do
      expect {
        tx.unconfirmed_update! gas_price: new_price
      }.to change {
        tx.gas_price
      }.to(new_price)
    end

    it "updates the ethereum transaction" do
      expect {
        tx.unconfirmed_update! gas_price: new_price
      }.to change {
        tx.raw_hex
      }.and change {
        tx.txid
      }
    end

    it "broadcasts the new transaction" do
      new_hex = nil
      expect_any_instance_of(Ethereum::Client).to receive(:send_raw_transaction) do |client, hex|
        new_hex = hex
      end

      tx.unconfirmed_update! gas_price: new_price

      expect(tx.raw_hex).to eq(new_hex)
    end

    context "when the transaction fails to broadcast" do
      let(:error_text) { "Not acknowledged, try again. Errors: ['Nonce too low.']" }
      before do
        allow_any_instance_of(Ethereum::Client).to receive(:send_raw_transaction)
          .and_raise(error_text)
      end

      it "does not update the transaction record" do
        old_price = tx.gas_price
        old_hex = tx.raw_hex
        old_id = tx.txid

        expect {
          tx.unconfirmed_update! gas_price: new_price
        }.to raise_error(error_text)

        expect(tx.gas_price).to eq old_price
        expect(tx.raw_hex).to eq old_hex
        expect(tx.txid).to eq old_id
      end
    end

    context "when the transaction has already been confirmed" do
      let(:confirmations) { 1 }

      it "does not broadcast the transaction" do
        expect_any_instance_of(Ethereum::Client).not_to receive(:send_raw_transaction)

        tx.unconfirmed_update! gas_price: new_price
      end

      it "does not update the transaction record" do
        old_price = tx.gas_price
        old_hex = tx.raw_hex
        old_id = tx.txid

        tx.unconfirmed_update! gas_price: new_price

        expect(tx.gas_price).to eq old_price
        expect(tx.raw_hex).to eq old_hex
        expect(tx.txid).to eq old_id
      end
    end
  end

end
