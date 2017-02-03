describe HttpRetriever, type: :model do

  describe ".get" do
    let(:url) { "https://www.example.com/api.json" }

    before { expect(HttpRetriever).to receive(:get).and_call_original }

    context "when the response is successfully retrieved" do
      let(:response_body) { SecureRandom.uuid }

      before do
        expect(HTTParty).to receive(:get)
          .with(url, {})
          .and_return(double body: response_body)
      end

      it "returns the body" do
        expect(HttpRetriever.get url).to eq(response_body)
      end

      context "when the response includes the UTF-8 BOM header" do
        let(:body) { {a: 1}.to_json }
        let(:response_body) { "\xEF\xBB\xBF#{body}" }

        it "parses the header out" do
          # example: http://www.w3schools.com/json/myTutorials.txt
          parsed = HttpRetriever.get url
          expect(parsed).to eq(body)
          expect(parsed.encoding.to_s).to eq('UTF-8')
        end
      end
    end

    context "when the response is unsuccessfully retrieved" do
      before do
        expect(HTTParty).to receive(:get)
          .with(url, {})
          .and_raise
      end

      it "returns nil" do
        expect(HttpRetriever.get url).to be_nil
      end
    end
  end

end
