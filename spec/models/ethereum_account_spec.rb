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

  describe "#best_nonce" do
    let(:account) { EthereumAccount.create address: ethereum_address, nonce: database_nonce }
    let(:database_nonce) { 100 }

    before do
      expect_any_instance_of(EthereumClient).to receive(:get_transaction_count)
        .with(account.address)
        .and_return(blockchain_nonce)
    end

    context "when the blockchain reports a higher nonce" do
      let(:blockchain_nonce) { 101 }

      it "returns the blockchain nonce" do
        expect(account.best_nonce).to eq(blockchain_nonce)
      end
    end

    context "when the database reports a higher nonce" do
      let(:blockchain_nonce) { 99 }

      it "returns the database nonce" do
        expect(account.best_nonce).to eq(database_nonce)
      end
    end
  end
end
