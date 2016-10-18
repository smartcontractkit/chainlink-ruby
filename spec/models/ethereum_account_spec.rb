describe EthereumAccount, type: :model do
  describe "validations" do
    let(:old_account) { EthereumAccount.create address: ethereum_address }

    it { is_expected.to have_valid(:address).when("0x#{SecureRandom.hex(20)}") }
    it { is_expected.not_to have_valid(:address).when(old_account.address, nil, '', '0x', SecureRandom.hex(20), "0x#{SecureRandom.hex(19)}") }
  end

  describe "test environment configuration" do
    it "has the same Ethereum default account as is seeded" do
      expect(ethereum_accounts(:default).address).to eq(ENV['ETHEREUM_ACCOUNT'])
    end
  end

  describe "#sign" do
    let(:account) { EthereumAccount.create key_pair: key_pair }
    let(:tx) { unsigned_ethereum_tx }

    context "when the account has a key pair" do
      let(:key_pair) { KeyPair.new }

      it "returns returns a signed transaction" do
        signed = account.sign tx
        expect(signed).not_to be_nil
        expect(signed.v).not_to be_nil
        expect(signed.r).not_to be_nil
        expect(signed.s).not_to be_nil
      end
    end

    context "when the account does not have a key pair" do
      let(:key_pair) { nil }

      it "returns nil" do
        expect(account.sign tx).to be_nil
      end
    end
  end

  describe "#send_transaction" do
    let(:key_pair) { KeyPair.new }
    let(:account) { EthereumAccount.create key_pair: key_pair, address: ethereum_address }
    let(:recipient) { ethereum_address }
    let(:options) do
      {
        gas_limit: 25_000,
        data: SecureRandom.hex,
        to: recipient,
      }
    end

    it "creates an ethereum transaction" do
      expect {
        account.send_transaction options
      }.to change {
        EthereumAccount.count
      }
    end

    it "increments the account's next nonce" do
      allow_any_instance_of(EthereumClient).to receive(:get_transaction_count)
        .and_return(0)

      expect {
        account.send_transaction options
      }.to change {
        account.reload.nonce
      }.by(+1)
    end
  end

  describe "#next_nonce" do
    let(:account) { EthereumAccount.create address: ethereum_address }
    let(:blockchain_nonce) { 1000 }
    let(:database_nonce) { 99 }

    before do
      account.ethereum_transactions.destroy_all

      allow_any_instance_of(EthereumClient).to receive(:get_transaction_count)
        .with(account.address)
        .and_return(blockchain_nonce)
    end

    context "when the account does NOT have a last nonce" do
      it "returns the database nonce" do
        expect(account.next_nonce).to eq(blockchain_nonce)
      end
    end

    context "when the account has a last nonce" do
      let!(:past_tx_nil) { factory_create :ethereum_transaction, account: account, nonce: nil }
      let!(:past_tx1) { factory_create :ethereum_transaction, account: account, nonce: (database_nonce - 1) }
      let!(:past_tx2) { factory_create :ethereum_transaction, account: account, nonce: database_nonce }

      it "returns the blockchain nonce" do
        expect(account.next_nonce).to eq(database_nonce + 1)
      end
    end
  end
end
