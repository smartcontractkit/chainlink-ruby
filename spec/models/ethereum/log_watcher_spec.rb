describe Ethereum::LogWatcher do

  describe "validations" do
    it { is_expected.to have_valid(:address).when(ethereum_address) }
    it { is_expected.not_to have_valid(:address).when(nil, '') }
  end

  describe "on create" do
    let(:watcher) { factory_build :ethereum_log_watcher }

    it "pulls the address from the body" do
      expect {
        watcher.save
      }.to change {
        watcher.address
      }.from(nil)
    end
  end

end
