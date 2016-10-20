describe EthereumContractConfirmer, type: :model do
  describe "#perform" do
    let!(:contract) { factory_create(:ethereum_oracle).ethereum_contract }
    let(:watcher) { EthereumContractConfirmer.new(contract) }
    let(:new_address) { ethereum_address }
    let(:response) { ethereum_receipt_response(contract_address: new_address).result }

    before do
      allow_any_instance_of(EthereumClient).to receive(:get_transaction_receipt)
        .with(contract.genesis_transaction.txid)
        .and_return(response)
    end

    it "changes the contract to confirmed" do
      expect {
        watcher.perform
      }.to change {
        EthereumContract.unconfirmed.count
      }.by(-1)
    end

    it "informs the ethereum contract that it has been confirmed" do
      expect(contract).to receive(:confirmed)
        .with(new_address)

      watcher.perform
    end
  end
end
