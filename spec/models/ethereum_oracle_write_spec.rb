describe EthereumOracleWrite, type: :model do

  describe "validations" do
    it { is_expected.to have_valid(:oracle).when(factory_create(:ethereum_oracle), factory_create(:ethereum_bytes32_oracle)) }
    it { is_expected.not_to have_valid(:oracle).when(nil) }

    it { is_expected.to have_valid(:txid).when(ethereum_txid) }
    it { is_expected.not_to have_valid(:txid).when(nil, '', "0x#{SecureRandom.hex(31)}") }

    it { is_expected.to have_valid(:value).when(nil, 'a') }
  end

end
