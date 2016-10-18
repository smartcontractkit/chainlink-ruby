describe EthereumTransaction, type: :model do

  describe "validations" do
    it { is_expected.to have_valid(:account).when(EthereumAccount.new) }
    it { is_expected.not_to have_valid(:account).when(nil) }

    it { is_expected.to have_valid(:txid).when("0x#{SecureRandom.hex(32)}") }
    it { is_expected.not_to have_valid(:txid).when(nil, '', "0x", SecureRandom.hex(32), "0x#{SecureRandom.hex(20)}") }
  end

end
