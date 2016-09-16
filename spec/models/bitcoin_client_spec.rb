describe BitcoinClient, type: :model do
  let(:client) { BitcoinClient.new }

  describe "#get_transaction" do
    let(:txid) { 'd6effb2dd567a6d7a6b4dcd478b39eb7460bd71bd3b812126d8bc86b4de35380' }
    let(:tx_hex) { '010000000195858b472cb0785323e563463c7805fa34bf78cdd4e60fda25f69af47907001c010000008b4830450221009e84af6ce44488c0db042308eaca732ff865c41be5b08cb481e25997a32584e2022000ee3e3aa4becae9cdea5f808f690b1be20104555db6334c9982a4153bc3f744014104b808685cce694ec8ad1df865546c8620420207baa0ec3a6af44f78451eb74dfd176a3932a6aaf960a0e3465b35339ec317ac8b3b87a6c3cc1f7507a24ba12d95ffffffff0210270000000000001976a91481e984e94bfa835868966aad8cf91061ad67c9e488ac13253100000000001976a9149b8afce10b876dd27972d04c0cfd04cd4d073bc588ac00000000' }

    before do
      expect_any_instance_of(BitcoinClient).to receive(:get_transaction)
        .and_call_original

      expect_any_instance_of(BlockCypherClient).to receive(:get_transaction_hex)
        .with(txid)
        .and_return(tx_hex)
    end

    it "parses out a transaction" do
      tx = client.get_transaction(txid)

      expect(tx.inputs.size).to eq(1)
      expect(tx.outputs.size).to eq(2)
      expect(tx.outputs.last.parsed_script.to_string).to eq("OP_DUP OP_HASH160 9b8afce10b876dd27972d04c0cfd04cd4d073bc5 OP_EQUALVERIFY OP_CHECKSIG")
    end
  end

  describe "#public_keys_for_tx" do
    let(:hex) { File.read 'spec/fixtures/bitcoin/txs/eaeb8ff72eeba597d77032ab6ee4770b4dace3f876b5c983e957425c8f06ccac.hex' }

    it "parses the public keys out of the input script sig" do
      pubs = client.public_keys_for_tx hex

      expect(pubs).to eq([
        "0272bafa5897b132730bf097e6f4175a772acca29aa5677cc871f2527c9687d280",
        "0247efaf54f2a477eb74af2455af80818dea5f31471130e141b9f446c4d60a637b",
        "024e5aa5fa40abc0d9fc2f1e08ce0aea62687d88490cca2b1c612efc1f8c8348bb"
      ])
    end
  end

  describe "#get_transaction_info" do
    let(:chain_response) { {} }

    it "creates an async job to follow an address" do
      allow_any_instance_of(BlockCypherClient).to receive(:get_transaction_info)
        .and_return(chain_response)

      expect(client.get_transaction_info SecureRandom.hex).to eq(chain_response)
    end
  end

end
