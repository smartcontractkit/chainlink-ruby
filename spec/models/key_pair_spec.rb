describe KeyPair, type: :model do
  describe "validations" do
    it { is_expected.to have_valid(:private_key).when(Bitcoin::Key.generate.priv, nil) }
    it { is_expected.to have_valid(:public_key).when(nil) }
  end

  describe "before create" do
    let(:key_pair) { KeyPair.new }

    it "generates a public key, private key pair" do
      expect(key_pair.public_key).to be_nil
      expect(key_pair.private_key).to be_nil

      key_pair.save

      expect(key_pair.public_key).to be_present
      expect(key_pair.private_key).to be_present
    end

    it "ensures a valid key pair" do
      expect {
        KeyPair.create
      }.to change {
        KeyPair.count
      }.by(+1)
    end
  end

  describe ".unowned" do
    subject { KeyPair.unowned }

    let!(:unowned) { KeyPair.create }
    let!(:owned) { factory_create(:local_ethereum_account).key_pair }

    it { is_expected.to include unowned }
    it { is_expected.not_to include owned }
  end

  describe ".bitcoin_default" do
    it "has the public key specified in the environment variables" do
      expect(KeyPair.bitcoin_default.public_key).to eq(ENV['BITCOIN_PUB_KEY'])
    end

    context "when the key pair specified is not available" do
      before do
        KeyPair.bitcoin_default.destroy
      end

      let!(:unowned1) { KeyPair.create }
      let!(:unowned2) { KeyPair.create }

      it "returns the first unowned key pair" do
        expect(KeyPair.bitcoin_default).to eq(KeyPair.unowned.first)
      end
    end
  end

  describe "#generate_keys" do
    context "when a private key already exists" do
      let(:key_pair) { KeyPair.new private_key: SecureRandom.hex(32) }

      it "does not change the private key" do
        expect {
          key_pair.generate_keys
        }.not_to change {
          key_pair.private_key
        }
      end
    end

    context "when a private key does not exist" do
      let(:key_pair) { KeyPair.new private_key: nil }

      it "does change the private key" do
        expect {
          key_pair.generate_keys
        }.to change {
          key_pair.private_key
        }.from(nil)
      end
    end
  end

  describe ".key_for_tx" do
    let(:tx_hex) { SecureRandom.hex }
    let(:key_pair) { KeyPair.create }

    it "looks up the public keys of a transaction" do
      expect_any_instance_of(BitcoinClient).to receive(:public_keys_for_tx)
        .with(tx_hex)
        .and_return([SecureRandom.hex, key_pair.public_key, SecureRandom])

      expect(KeyPair.key_for_tx tx_hex).to eq(key_pair)
    end
  end
end
