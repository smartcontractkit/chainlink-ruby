class Ethereum::ConfirmationWatcher

  include HasEthereumClient

  def self.perform
    EthereumTransaction.unconfirmed.each do |tx|
      new(tx).delay.perform
    end
  end

  def initialize(tx)
    @tx = tx
  end

  def perform
    receipt = ethereum.get_transaction_receipt tx.txid

    if receipt && receipt['blockNumber']
      tx.update_attributes confirmations: 1
    else
      ethereum.send_raw_transaction tx.raw_hex
    end
  end


  private

  attr_reader :tx

end
