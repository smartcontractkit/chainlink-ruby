describe Ethereum::OracleUpdater, type: :model do
  let(:oracle_updater) { Ethereum::OracleUpdater.new(oracle) }

  describe "#perform" do
    let(:account) { oracle.account }
    let(:contract) { oracle.ethereum_contract }
    let(:code_template) { contract.template }
    let!(:oracle) { factory_create :ethereum_oracle }
    let(:tx) { factory_create :ethereum_transaction }
    let(:current_value) { "Hi Mom!" }
    let(:current_hex) { "4869204d6f6d2100000000000000000000000000000000000000000000000000" }

    before do
      expect(account).to receive(:send_transaction)
        .with({
          data: "#{code_template.write_address}#{current_hex}",
          gas_limit: 100_000,
          to: contract.address,
        })
        .and_return(tx)
    end

    it "creates an oracle update record" do
      expect {
        oracle_updater.perform current_hex, current_value
      }.to change {
        oracle.writes.count
      }.by(+1)
    end

    it "returns the new oracle write" do
      result = oracle_updater.perform current_hex, current_value
      expect(result).to be_an EthereumOracleWrite
      expect(result).to be_persisted
    end

    context "when the transaction fails to broadcast" do
      let(:tx) { factory_build :ethereum_transaction, txid: nil }

      it "does NOT create a new oracle write" do
        expect {
          oracle_updater.perform current_hex, current_value
        }.not_to change {
          oracle.writes.count
        }
      end

      it "returns the unpersisted oracle write" do
        result = oracle_updater.perform current_hex, current_value
        expect(result).to be_an EthereumOracleWrite
        expect(result).not_to be_persisted
      end
    end
  end
end
