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

    context "when the transaction fails to broadcast" do
      after_count = oracle.reload.writes.count

      it "does NOT create a new oracle write" do
        before_count = oracle.writes.count

        expect {
          oracle_updater.perform
        }.to raise_error "Invalid Ethereum TX! \n\ntxid: \n\nhex:"

        after_count = oracle.reload.writes.count
        expect(before_count).to eq(after_count)
      end
    end
  end
end
