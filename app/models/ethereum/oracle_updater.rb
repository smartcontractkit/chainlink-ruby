class Ethereum::OracleUpdater

  include HasEthereumClient

  def initialize(oracle)
    @oracle = oracle
    @account = oracle.account
    @address = oracle.contract_address
    @update_address = oracle.contract_write_address
  end

  def perform(hex, value)
    tx = send_data(hex)

    oracle.writes.create txid: tx.txid, value: value
  end


  private

  attr_reader :account, :address, :oracle, :update_address

  def set_current_value(value)
    @hex_value = value
  end

  def send_data(hex)
    @tx ||= account.send_transaction({
      data: "#{update_address}#{hex}",
      gas_limit: 100_000,
      to: address,
    })
  end

end
