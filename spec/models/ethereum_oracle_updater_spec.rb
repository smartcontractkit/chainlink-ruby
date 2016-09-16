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

    it "gets the most recent value from the API" do
      expect(account).to receive(:send_transaction)
        .with({
          data: "#{code_template.write_address}4869204d6f6d21".htb,
          gas_limit: 250_000,
          to: contract.address,
        })
        .and_return(ethereum_receipt_response)

      oracle_updater.perform
    end

    it "creates an oracle update record" do
      expect {
        oracle_updater.perform
      }.to change {
        oracle.writes.count
      }.by(+1)
    end
  end
end
