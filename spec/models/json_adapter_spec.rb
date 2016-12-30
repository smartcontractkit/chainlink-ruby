describe JsonAdapter do

  describe "validations" do
    it { is_expected.to have_valid(:fields).when('recent', ['recent', 'high']) }
    it { is_expected.not_to have_valid(:fields).when(nil, '', []) }

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

end
