describe EthereumOracle, type: :model do
  describe "validations" do
    it { is_expected.to have_valid(:endpoint).when('https://bitstamp.net/api/ticker/', 'http://example.net/api?foo=bar|baz') }
    it { is_expected.not_to have_valid(:endpoint).when(nil, '', 'ftp://bitstamp.net/api/ticker/', 'http://example.net/api ?foo=bar|baz') }

    it { is_expected.to have_valid(:ethereum_contract).when(EthereumContract.new) }
    it { is_expected.not_to have_valid(:ethereum_contract).when(nil) }

    it { is_expected.to have_valid(:field_list).when('recent', 'recent?!?0?!?high') }
    it { is_expected.not_to have_valid(:field_list).when(nil, '') }
  end

  describe ".current" do
    subject { EthereumOracle.current }
    let(:current_term) { factory_build :term, start_at: 1.year.ago, end_at: 1.minute.from_now }
    let(:past_term) { factory_build :term, start_at: 1.year.ago, end_at: 1.minute.ago }
    let!(:current) { ethereum_oracle_factory(term: current_term) }
    let!(:past) { ethereum_oracle_factory(term: past_term) }

    it { is_expected.to include current }
    it { is_expected.not_to include past }
  end

  describe "#current_value" do
    let(:oracle) { EthereumOracle.new }
    let(:response_body) { {a: 1}.to_json }
    let(:rando) { SecureRandom.hex }

    it "reaches out to the web and parses the json" do
      expect(HttpRetriever).to receive(:get)
        .with(oracle.endpoint)
        .and_return(response_body)

      expect(JsonTraverser).to receive(:parse)
        .with(response_body, oracle.fields)
        .and_return(rando)

      expect(oracle.current_value).to eq(rando)
    end
  end
end
