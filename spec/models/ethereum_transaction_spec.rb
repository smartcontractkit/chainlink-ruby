describe EthereumTransaction, type: :model do

  describe "validations" do
    it { is_expected.to have_valid(:account).when(EthereumAccount.new) }
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

end
