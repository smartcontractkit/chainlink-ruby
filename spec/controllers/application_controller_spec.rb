describe ApplicationController, type: :controller do

  describe "#identity" do
    it "returns all of the identity in json" do
      get :identity

      expect(response_json.name).to eq ENV['NODE_NAME']
      expect(response_json.bitcoin_pub).to eq ENV['BITCOIN_PUB_KEY']
    end
  end

end
