class Ethereum::OracleUpdater

  include HasEthereumClient

  def initialize(oracle)
    @oracle = oracle
    @account = oracle.account
    @address = oracle.contract_address
    @update_address = oracle.contract_write_address
  end

  def perform(value)
    set_current_value value

    oracle.writes.create txid: tx.txid, value: current_value
  end


  private

  attr_reader :account, :address, :current_value, :oracle, :update_address

  def set_current_value(value)
    @current_value = value.to_s[0..31]
  end

  def tx
    @tx ||= account.send_transaction({
      data: "#{update_address}#{ethereum.format_bytes32_hex current_value}",
      gas_limit: 100_000,
      to: address,
    })
  end

end
