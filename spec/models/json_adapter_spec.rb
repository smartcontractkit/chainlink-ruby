describe JsonAdapter do

  describe "validations" do
    it { is_expected.to have_valid(:basic_auth_password).when(nil, '', SecureRandom.base64) }

    it { is_expected.to have_valid(:basic_auth_username).when(nil, '', SecureRandom.base64) }

    it { is_expected.to have_valid(:fields).when('recent', ['recent', 'high']) }
    it { is_expected.not_to have_valid(:fields).when(nil, '', []) }

    it { is_expected.to have_valid(:headers).when(nil, {}, {a: 1}) }

    it { is_expected.to have_valid(:request_type).when('GET') }
    it { is_expected.not_to have_valid(:request_type).when('POST') }

    it { is_expected.to have_valid(:url).when('https://bitstamp.net/api/ticker/', 'http://example.net/api?foo=bar|baz') }
    it { is_expected.not_to have_valid(:url).when(nil, '', 'ftp://bitstamp.net/api/ticker/', 'http://example.net/api ?foo=bar|baz') }
  end

  describe "on create" do
    let(:adapter) { factory_build :json_adapter }

    it "sets the request type to 'GET'" do
      expect {
        adapter.save
      }.to change {
        adapter.request_type
      }.from(nil).to('GET')
    end
  end

  describe "#get_status" do
    let(:adapter) { factory_create :json_adapter }
    let(:subtask) { factory_create :subtask, adapter: adapter }
    let(:snapshot) { factory_create :adapter_snapshot, subtask: subtask }
    let(:_params) { {dont: 'matter'} }
    let(:response) { double }
    let(:value) { '22,the-moon' }

    before do
      allow(HttpRetriever).to receive(:get)
        .with(adapter.url, {})
        .and_return(response)

      allow(JsonTraverser).to receive(:parse)
        .with(response, adapter.fields)
        .and_return(value)
    end

    it "formats the parsed response of the HTTP request for a snapshot" do
      status = adapter.get_status(snapshot, _params)

      expect(status.errors).to be_empty
      expect(status.fulfilled).to be true
      expect(status.description).to be_nil
      expect(status.description_url).to be_nil
      expect(status.details).to eq(value: value)
      expect(status.summary).to eq("The parsed JSON returned \"#{value}\".")
      expect(status.value).to eq(value)
    end
  end

end
