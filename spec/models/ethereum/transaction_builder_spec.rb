describe Ethereum::TransactionBuilder, type: :model do
  let(:account) { factory_create :local_ethereum_account }
  let(:builder) { Ethereum::TransactionBuilder.new account }

  describe "#perform" do
    let(:gas_price) { 123_456_789 }
    let(:recipient) { new_ethereum_address }
    let(:options) { Hash.new }

    before do
      allow_any_instance_of(Ethereum::Client).to receive(:gas_price)
        .and_return(gas_price)
    end

    it "creates a new transaction" do
      expect {
        builder.perform options
      }.to change {
        account.reload.ethereum_transactions.count
      }.by(+1)
    end

    it "fills in defaults for the transaction" do
      next_nonce = account.next_nonce

      transaction = builder.perform options

      expect(transaction.data).to eq('')
      expect(transaction.gas_limit).to eq(21_000)
      expect(transaction.gas_price).to eq(gas_price)
      expect(transaction.nonce).to eq(next_nonce)
      expect(transaction.to).to eq(nil)
      expect(transaction.value).to eq(0)
    end

    it "creates a transaction that is signed by the account" do
      transaction = builder.perform options
      tx = Eth::Tx.decode transaction.raw_hex

      expect(tx.from).to eq(account.address)
    end
  end

end
