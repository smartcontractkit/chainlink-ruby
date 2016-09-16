describe EthereumOracleWrite, type: :model do
  describe "validations" do
    it { is_expected.to have_valid(:oracle).when(EthereumOracle.new) }
    it { is_expected.not_to have_valid(:oracle).when(nil) }

    it { is_expected.to have_valid(:txid).when(nil, 'a') }

    it { is_expected.to have_valid(:value).when(nil, 'a') }
  end
end
