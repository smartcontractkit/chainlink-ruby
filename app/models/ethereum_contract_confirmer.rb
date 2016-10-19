class EthereumContractConfirmer

  include HasEthereumClient

  def self.perform
    EthereumContract.unconfirmed.each do |contract|
      new(contract).delay.perform
    end
  end

  def initialize(contract)
    @contract = contract
  end

  def perform
    result = ethereum.get_transaction_receipt(txid)
    if contract_address = result && result['contractAddress']
      contract.confirmed contract_address
    end
  end


  private

  attr_reader :contract

  def txid
    @txid ||= contract.genesis_transaction.txid
  end

end
