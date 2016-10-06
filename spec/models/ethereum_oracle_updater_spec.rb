describe EthereumOracleUpdater, type: :model do
  let(:oracle_updater) { EthereumOracleUpdater.new(oracle) }

  before do
    allow_any_instance_of(EthereumOracle).to receive(:current_value)
      .and_return("Hi Mom!")
  end

  describe "#perform" do
    let(:account) { contract.account }
    let(:contract) { ethereum_contract_factory address: ethereum_address }
    let(:code_template) { contract.template }
    let!(:oracle) { ethereum_oracle_factory ethereum_contract: contract }
    let(:tx) { factory_create :ethereum_transaction }

    before do
      expect(account).to receive(:send_transaction)
        .with({
          data: "#{code_template.write_address}4869204d6f6d21".htb,
          gas_limit: 100_000,
          to: contract.address,
        })
        .and_return(tx)
    end

    it "creates an oracle update record" do
      expect {
        oracle_updater.perform
      }.to change {
        oracle.writes.count
      }.by(+1)
    end

    it "returns the new oracle write" do
      result = oracle_updater.perform
      expect(result).to be_an EthereumOracleWrite
      expect(result).to be_persisted
    end

    context "when the transaction fails to broadcast" do
      let(:tx) { factory_build :ethereum_transaction, txid: nil }

      it "does NOT create a new oracle write" do
        expect {
          oracle_updater.perform
        }.not_to change {
          oracle.writes.count
        }
      end

      it "returns the new oracle write" do
        result = oracle_updater.perform
        expect(result).to be_an EthereumOracleWrite
        expect(result).not_to be_persisted
      end
    end
  end
end
