describe JsonReceiver do

  describe "validations" do
    it { is_expected.to have_valid(:path).when(['whatever'], 'andEver') }
    it { is_expected.not_to have_valid(:path).when(nil, '', [], [nil], ['and', nil]) }
  end

  describe "on create" do
    let(:receiver) { factory_build :json_receiver }

    it "generates an external ID" do
      expect {
        receiver.save
      }.to change {
        receiver.xid
      }.from(nil)
    end
  end

end
