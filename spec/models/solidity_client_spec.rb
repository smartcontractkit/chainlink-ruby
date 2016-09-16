describe SolidityClient, type: :model do
  describe "#compile" do
    let(:solidity) { SolidityClient.new }
    let(:body) { SecureRandom.hex }

    it "makes a request to the Solidity service" do
      expect(SolidityClient).to receive(:post)
        .with('/compile', {
          basic_auth: {},
          body: {
            solidity: body
          },
          headers: {},
        })
        .and_return(http_response body: {a: 1}.to_json)

      solidity.compile body
    end
  end
end
