describe JsonReceiverRequest do

  describe "validation" do
    it { is_expected.to have_valid(:data).when(nil, {a: 1}) }

    it { is_expected.to have_valid(:json_receiver).when(factory_create(:json_receiver)) }
    it { is_expected.not_to have_valid(:json_receiver).when(nil) }
  end

  describe "on create" do
    let(:request) { factory_build :json_receiver_request }
    let(:receiver) { request.json_receiver }

    it "requests a snapshot from its adapter" do
      expect(receiver).to receive_message_chain(:delay, :snapshot_requested)
        .with(request)

      request.save
    end
  end

end
