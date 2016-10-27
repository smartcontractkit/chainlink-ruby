describe EthereumAccount, type: :model do
  describe "validations" do
    let(:old_account) { EthereumAccount.create address: ethereum_address }

    it { is_expected.to have_valid(:address).when("0x#{SecureRandom.hex(20)}", nil) }
    it { is_expected.not_to have_valid(:address).when(old_account.address, '', '0x', SecureRandom.hex(20), "0x#{SecureRandom.hex(19)}") }
  end

  describe "on create" do
    context "when no address is specified" do
      it "creates a new key pair" do
        account = EthereumAccount.new
        expect {
          account.save
        }.to change {
          KeyPair.count
        }.by(+1)

        expect(account.key_pair).to eq(KeyPair.last)
      end
    end

    context "when an address is specified" do
      it "does NOT create a key pair" do
        expect {
          EthereumAccount.create address: ethereum_address
        }.not_to change {
          KeyPair.count
        }
      end
    end
  end

  describe ".local" do
    subject { EthereumAccount.local }

    let!(:local) { factory_create :local_ethereum_account }
    let!(:not_local) { factory_create :ethereum_account }

    it { is_expected.to include local }
    it { is_expected.not_to include not_local }
  end

  describe ".default" do
    let!(:local1) { factory_create :local_ethereum_account }
    let!(:local2) { factory_create :local_ethereum_account }
    let!(:not_local1) { factory_create :ethereum_account }
    let!(:not_local2) { factory_create :ethereum_account }

    it "has the same Ethereum default account as is seeded" do
      expect(EthereumAccount.default.address).to eq(ENV['ETHEREUM_ACCOUNT'])
    end

    context "when the account specified is not available" do
      before do
        EthereumAccount.find_by(address: ENV['ETHEREUM_ACCOUNT']).destroy
      end

      it "uses the first local account" do
        expect(EthereumAccount.default).to eq(EthereumAccount.local.first)
      end
    end
  end

  describe "#sign" do
    let(:tx) { unsigned_ethereum_tx }

    context "when the account has a key pair" do
      let(:account) { factory_create :local_ethereum_account }

      it "returns returns a signed transaction" do
        signed = account.sign tx
        expect(signed).not_to be_nil
        expect(signed.v).not_to be_nil
        expect(signed.r).not_to be_nil
        expect(signed.s).not_to be_nil
      end
    end

    context "when the account does not have a key pair" do
      let(:account) { factory_create :ethereum_account }

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

    it "creates a valid transaction record" do
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
        account.reload.next_nonce
      }.by(+1)
    end
  end

  describe "#next_nonce" do
    let(:account) { factory_create :ethereum_account }
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
