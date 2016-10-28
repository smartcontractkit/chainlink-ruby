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
