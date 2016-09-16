describe JsonTraverser, type: :model do
  describe ".parse" do
    subject { JsonTraverser.parse body, keys }
    let(:body) do
      {
        first: {
          second: {
            third: 'you win!'
          }
        },
        list: [
          {name: "your mom"},
          {name: "your momma's mom"}
        ]
      }.to_json
    end
    let(:keys) { ['first', 'second', 'third'] }

    it "returns nil for nonexistent results" do
      result = JsonTraverser.parse body, ['first', 'second', 'third']
      expect(result).to eq 'you win!'
    end

    it "returns nil for nonexistent results" do
      result = JsonTraverser.parse body, ['first', 'third', 'second']
      expect(result).to be_nil
    end

    it "parses arrays" do
      result = JsonTraverser.parse body, ['list', '0', 'name']
      expect(result).to eq 'your mom'
    end

    it "parses strings" do
      result = JsonTraverser.parse body, ['list', '0', 'name', '2']
      expect(result).to eq 'u'
    end

    it "does not blow up when traversing an array out of index" do
      result = JsonTraverser.parse body, ['list', '100', 'name']
      expect(result).to be_nil
    end

    it "does not parse backwards with negative numbers" do
      result = JsonTraverser.parse body, ['list', '-1', 'name']
      expect(result).to be_nil
    end

    context "when the body is nil" do
      let(:body) { nil }
      it { is_expected.to be_nil }
    end

    context "when the body is an empty string" do
      let(:body) { '' }
      it { is_expected.to be_nil }
    end

    context "when the body is not JSON" do
      let(:body) { '<html><body>Hi!</body></html>' }
      it { is_expected.to be_nil }
    end
  end
end
