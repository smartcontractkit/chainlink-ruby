describe JsonParser, type: :model do
  describe ".perform" do
    let(:value) { SecureRandom.hex }
    let(:json) { JsonParser.perform(body) }

    context "when standard JSON is passed back" do
      let(:body) { {key: value}.to_json }

      it "parses the JSON" do
        expect(json['key']).to eq(value)
      end
    end

    context "when standard JSON contains NaN or Infinity" do
      let(:body) { '{"a": 1, "key": NaN, "key2": Infinity}' }

      it "parses the JSON" do
        expect(json['key'].to_s).to eq 'NaN'
        expect(json['key2'].to_s).to eq 'Infinity'
      end
    end

    context "when JSON has HTML mixed in" do
      let(:body) { "{\"DividendData\":[{\"Desc\":\"Splits:5:4<br>\",\"Type\":\"Splits\"}]}" }

      it "parses the JSON" do
        expect(json['DividendData'][0]['Desc']).to eq 'Splits:5:4<br>'
      end
    end
  end
end
