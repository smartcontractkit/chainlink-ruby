describe JsonReceiverRequest do

  describe "validation" do
    it { is_expected.to have_valid(:data).when(nil, {a: 1}) }

    it { is_expected.to have_valid(:json_receiver).when(factory_create(:json_receiver)) }
    it { is_expected.not_to have_valid(:json_receiver).when(nil) }
  end

end
