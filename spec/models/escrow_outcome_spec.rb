describe EscrowOutcome, type: :model do

  describe "validations" do
    subject { factory_create :escrow_outcome }

    it { is_expected.to have_valid(:result).when('success', 'failure') }
    it { is_expected.not_to have_valid(:result).when(nil, '', 'anything') }

    it { is_expected.to have_valid(:term).when(factory_create(:term)) }
    it { is_expected.not_to have_valid(:term).when(nil) }

    it { is_expected.to have_valid(:transaction_hex).when(SecureRandom.hex) }
    it { is_expected.not_to have_valid(:transaction_hex).when(nil, '') }
  end

  describe "#transaction_hexes" do
    let(:escrow) do
      factory_create(:escrow_outcome, {
        transaction_hexes: transaction_hexes
      }).tap(&:reload)
    end

    context "when multiple hexes are set" do
      let(:transaction_hexes) { [SecureRandom.hex, SecureRandom.hex] }

      it "returns an array of multiple hexes" do
        expect(escrow.transaction_hexes).to match_array(transaction_hexes)
      end
    end

    context "when an array of one hex is set" do
      let(:transaction_hexes) { [SecureRandom.hex] }

      it "returns an array one hex" do
        expect(escrow.transaction_hexes).to match_array(transaction_hexes)
      end
    end

    context "when a string of one hex is passed in" do
      let(:transaction_hexes) { SecureRandom.hex }

      it "returns an array of one hex" do
        expect(escrow.transaction_hexes).to match_array([transaction_hexes])
      end
    end
  end

  describe "#signatures" do
    let(:key1) { KeyPair.create }
    let(:key2) { KeyPair.create }
    let(:tx_hex1) { SecureRandom.hex }
    let(:tx_hex2) { SecureRandom.hex }
    let(:bitcoin) { instance_double BitcoinClient }
    let(:escrow) { factory_create :escrow_outcome, transaction_hexes: [tx_hex1, tx_hex2] }

    before do
      allow(BitcoinClient).to receive(:new).and_return(bitcoin)

      allow(KeyPair).to receive(:key_for_tx)
        .with(tx_hex1).and_return(key1)

      allow(KeyPair).to receive(:key_for_tx)
        .with(tx_hex2).and_return(key2)
    end

    it "signs each transaction hex" do
      expect(bitcoin).to receive(:signatures_for)
        .with(tx_hex1, key1).and_return(['sig1'])

      expect(bitcoin).to receive(:signatures_for)
        .with(tx_hex2, key2).and_return(['sig2a', 'sig2b'])

      expect(escrow.signatures).to eq([['sig1'], ['sig2a', 'sig2b']])
    end
  end

end
