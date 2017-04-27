describe JsonReceiver::RequestsController, type: :controller do

  describe "#create" do
    let(:receiver) { factory_create :json_receiver }

    it "creates a json receiver request record" do
      expect {
        post :create, json_receiver_id: receiver.xid, whatever: 'and ever'
      }.to change {
        receiver.requests.count
      }.by(+1)
      expect(response).to be_success

      req = JsonReceiverRequest.last
      expect(req.data['whatever']).to eq('and ever')
    end

    context "when the receiver ID is not valid" do
      it "returns a 404" do
        expect {
          post :create, json_receiver_id: receiver.xid[1..-1], whatever: 'and ever'
        }.not_to change {
          receiver.requests.count
        }

        expect(response).to be_not_found
      end
    end
  end

end
