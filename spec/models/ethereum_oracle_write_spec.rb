describe EthereumOracleWrite, type: :model do

  describe "validations" do
    it { is_expected.to have_valid(:oracle).when(factory_create(:ethereum_oracle), factory_create(:ethereum_bytes32_oracle)) }
    it { is_expected.not_to have_valid(:oracle).when(nil) }

    it { is_expected.to have_valid(:txid).when('a') }
    it { is_expected.not_to have_valid(:txid).when(nil, '') }

    it { is_expected.to have_valid(:value).when(nil, 'a') }
  end

end
