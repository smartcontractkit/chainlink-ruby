describe BitcoinClient::SignatureBuilder, type: :model do
  describe ".perform", bitcoin_network: :bitcoin do
    let(:bitcoin) { BitcoinClient.new }
    let(:prev_tx1) { tx_from_hex(File.read 'spec/fixtures/bitcoin/txs/eb5169f4fa8c52ccaf28f3aca5c4b8f0a4288412487b9318fd4df8b84db630c2.hex') }
    let(:prev_tx2) { tx_from_hex(File.read 'spec/fixtures/bitcoin/txs/6d6ee67f37039eabaa181ab77d92a0325df7a6130c81e006ab9eb40dd7990fd0.hex') }
    let(:key_pair1) { KeyPair.create(private_key: '56f121bda6e97513c7c411ec3d882a95c6c4ad57e172f56d72948d06c2a78e75') }
    let(:key_pair2) { KeyPair.create(private_key: '6143c5c62c0902f5f5f20e89450af86cd1f0197488a45a0fff1e94e597eaa0bc') }
    let(:unsigned_tx) { File.read 'spec/fixtures/bitcoin/txs/eaeb8ff72eeba597d77032ab6ee4770b4dace3f876b5c983e957425c8f06ccac.hex' }
    let(:signatures1) { bitcoin.signatures_for unsigned_tx, key_pair1 }
    let(:signatures2) { bitcoin.signatures_for unsigned_tx, key_pair2 }
    let(:signed1_tx) { bitcoin.add_signatures(signatures: signatures1, tx: unsigned_tx).tx }
    let(:signed2_tx) { bitcoin.add_signatures(signatures: signatures2, tx: signed1_tx).tx }

    it "signs multiple inputs of a multisig(2/3) transaction" do
      expect(signed2_tx.verify_input_signature 0, prev_tx1, Time.now.to_i, {verify_dersig: true}).to be_truthy
      expect(signed2_tx.verify_input_signature 1, prev_tx2, Time.now.to_i, {verify_dersig: true}).to be_truthy
    end
  end
end
