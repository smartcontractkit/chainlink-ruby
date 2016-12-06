describe SolidityClient, type: :model do
  describe ".compile" do
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

      SolidityClient.compile body
    end
  end

  describe ".sol_abi" do
    let(:json_abi) { File.read 'spec/fixtures/ethereum/solidity/Oracle.json-abi' }
    let(:expected_sol_abi) { File.read 'spec/fixtures/ethereum/solidity/Oracle.sol-abi' }

    it "parses an importable Solidity ABI" do
      sol_abi = SolidityClient.sol_abi 'Oracle', json_abi
      expect(sol_abi.strip).to eq(expected_sol_abi.strip)
    end
  end
end
