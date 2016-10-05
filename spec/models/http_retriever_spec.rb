describe HttpRetriever, type: :model do

  describe ".get" do
    let(:url) { "https://www.example.com/api.json" }

    before { expect(HttpRetriever).to receive(:get).and_call_original }

    context "when the response is successfully retrieved" do
      let(:response_body) { double }

      before do
        expect(HTTParty).to receive(:get)
          .with(url)
          .and_return(double body: response_body)
      end

      it "returns the body" do
        expect(HttpRetriever.get url).to eq(response_body)
      end
    end

    context "when the response is unsuccessfully retrieved" do
      before do
        expect(HTTParty).to receive(:get)
          .with(url)
          .and_raise
      end

      it "returns nil" do
        expect(HttpRetriever.get url).to be_nil
      end
    end
  end

end
