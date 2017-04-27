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

  describe "#value" do
    let(:path) { ['following', '1', 'receivers', 'path'] }
    let(:receiver) { factory_create :json_receiver, path: path }
    let(:request) do
      factory_create(:json_receiver_request, {
        data: {
          following: [nil, {receivers: {path: 'SUCCESS!!'}}]
        },
        json_receiver: receiver
      })
    end

    it "returns the value of the receiver's path" do
      expect(request.value).to eq('SUCCESS!!')
    end
  end

end
