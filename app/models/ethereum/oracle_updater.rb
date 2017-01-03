class Ethereum::OracleUpdater

  include HasEthereumClient

  def initialize(oracle)
    @oracle = oracle
    @account = oracle.account
    @address = oracle.address
    @write_address = oracle.write_address
  end

  def perform(value)
    set_current_value value

    tx = account.send_transaction({
      data: "#{write_address}#{ethereum.format_bytes32_hex current_value}",
      gas_limit: 100_000,
      to: oracle.address,
    })

    oracle.writes.create txid: tx.txid, value: current_value
  end


  private

  attr_reader :account, :address, :current_value, :oracle, :write_address

  def set_current_value(value)
    @current_value = value.to_s[0..31]
  end

end
