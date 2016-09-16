describe EthereumTransaction, type: :model do

  describe "validations" do
    it { is_expected.to have_valid(:account).when(EthereumAccount.new) }
    it { is_expected.not_to have_valid(:account).when(nil) }

    it { is_expected.to have_valid(:txid).when("0x#{SecureRandom.hex(32)}") }
    it { is_expected.not_to have_valid(:txid).when(nil, '', "0x", SecureRandom.hex(32), "0x#{SecureRandom.hex(20)}") }
  end

  describe "on create" do
    let(:transaction) { EthereumTransaction.new raw_hex: hex }

    context "when the hex is present" do
      let(:hex) { SecureRandom.hex }
      let(:txid) { ethereum_txid }

      it "does create a new transaction on the blockchain" do
        expect_any_instance_of(EthereumClient).to receive(:send_raw_transaction)
          .with(hex)
          .and_return(double txid: txid)

        transaction.save

        expect(transaction.txid).to eq(txid)
      end
    end

    context "when the hex is NOT present" do
      let(:hex) { nil }

      it "does NOT try to create a new transaction on the blockchain" do
        expect_any_instance_of(EthereumClient).not_to receive(:send_raw_transaction)

        transaction.save
      end
    end
  end

end
