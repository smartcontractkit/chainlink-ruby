describe EthereumClient, type: :model do
  let(:ethereum) { EthereumClient.new }
  let(:random_id) { 7357 }

  before do
    allow(HttpClient).to receive(:random_id).and_return(random_id)
  end

  describe "#create_transaction" do
    let(:account) { EthereumAccount.new address: ethereum_address }
    let(:data) { SecureRandom.hex }
    let(:gas_amount) { Random.rand(1_000_000) }
    let(:gas_price) { ethereum_gas_price }
    let(:txid) { ethereum_txid }
    let(:stubbed_response) { ethereum_create_transaction_response(txid: txid) }

    it "posts a new transaction to Ethereum" do
      expect(EthereumClient).to receive(:post)
        .with('/', {
          basic_auth: instance_of(Hash),
          body: {
            id: random_id,
            jsonrpc: '2.0',
            method: 'eth_sendTransaction',
            params: [{
              data: "0x#{data}",
              from: account.address,
              gas: "0x#{gas_amount.to_s(16)}",
              gasPrice: gas_price,
              to: nil,
              value: nil,
            }]
          }.to_json,
          headers: instance_of(Hash)
        }).and_return(http_response body: stubbed_response.to_json)

      response = EthereumClient.new.create_transaction({
        gas: gas_amount,
        gas_price: gas_price,
        from: account,
        data: data
      })

      expect(response.txid).to eq(txid)
    end
  end

  describe "#get_transaction_receipt" do
    let(:txid) { ethereum_txid }

    it "posts a new transaction to Ethereum" do
      expect(EthereumClient).to receive(:post)
        .with('/', {
          basic_auth: instance_of(Hash),
          body: {
            id: 7357,
            jsonrpc: '2.0',
            method: 'eth_getTransactionReceipt',
            params: [txid]
          }.to_json,
          headers: instance_of(Hash)
        }).and_return(http_response body: ethereum_receipt_response(transaction_hash: txid).to_json)

      response = EthereumClient.new.get_transaction_receipt(txid)

      expect(response.transactionHash).to eq(txid)
    end
  end

  describe "#format_string_hex" do
    let(:output) { ethereum.format_string_hex string }
    let(:string) { Faker::Lorem.paragraph.first(size) }
    let(:byte_format) { output[0..63].to_i(16) }
    let(:length) { output[64..127].to_i(16) }
    let(:hex_message) { output[128..-1] }

    context "when the string is less than 32 bytes" do
      let(:size) { 30 }
      it { expect(byte_format).to equal(32) }
      it { expect(length).to equal(size) }
      it { expect(hex_message.size).to equal(64) }
      it { expect(ethereum.hex_to_utf8 hex_message).to eq(string) }
    end

    context "when the string is 32 bytes" do
      let(:size) { 32 }
      it { expect(byte_format).to equal(32) }
      it { expect(length).to equal(size) }
      it { expect(hex_message.size).to equal(128) }
      it { expect(ethereum.hex_to_utf8 hex_message).to eq(string) }
    end

    context "when the string is less than 64 bytes" do
      let(:size) { 63 }
      it { expect(byte_format).to equal(32) }
      it { expect(length).to equal(size) }
      it { expect(hex_message.size).to equal(128) }
      it { expect(ethereum.hex_to_utf8 hex_message).to eq(string) }
    end

    context "when the string is less than 96 bytes" do
      let(:size) { 95 }
      it { expect(byte_format).to equal(32) }
      it { expect(length).to equal(size) }
      it { expect(hex_message.size).to equal(192) }
      it { expect(ethereum.hex_to_utf8 hex_message).to eq(string) }
    end

    it "works with real expamples" do
      result = ethereum.format_string_hex 'Hi Mom!'
      expect(result).to eq('000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000074869204d6f6d2100000000000000000000000000000000000000000000000000')
    end

    context "with characters that require more than 1 byte" do
      let(:string) { "San Francisco Torn as Some See ‘Street Behavior’ Worsen" }
      let(:size) { string.size }

      it { expect(byte_format).to equal(32) }
      it { expect(length).to equal(size + 4) }
      it { expect(hex_message.size).to equal(128) }
      it { expect(ethereum.hex_to_utf8 hex_message).to eq(string) }
    end
  end

  describe "#format_bytes32_hex" do
    let(:output) { ethereum.format_bytes32_hex string }
    let(:string) { SecureRandom.base64(size * 2).first(size) }

    context "when the string is less than 32 bytes" do
      let(:size) { 30 }
      it { expect(output.size).to equal(size * 2) }
      it { expect(ethereum.hex_to_utf8 output).to eq(string) }
    end
  end

  describe "#send_raw_transaction" do
    let(:tx_hex) { SecureRandom.hex }
    let(:txid) { ethereum_txid }
    let(:stubbed_response) { ethereum_create_transaction_response(txid: txid) }

    it "posts a new transaction to Ethereum" do
      expect(EthereumClient).to receive(:post)
        .with('/', {
          basic_auth: instance_of(Hash),
          body: {
            id: random_id,
            jsonrpc: '2.0',
            method: 'eth_sendRawTransaction',
            params: [tx_hex]
          }.to_json,
          headers: instance_of(Hash)
        }).and_return(http_response body: stubbed_response.to_json)

      response = EthereumClient.new.send_raw_transaction(tx_hex)
      expect(response.txid).to eq(txid)
    end
  end
end
