class EthereumOracleUpdater

  include HasEthereumClient

  def self.perform(oracle_id)
    oracle = EthereumOracle.find(oracle_id)
    new(oracle).perform
  end

  def initialize(oracle)
    @oracle = oracle
    @contract = oracle.ethereum_contract
    @account = contract.account
  end

  def perform
    begin
      txid = account.send_transaction({
        data: "#{write_address}#{ethereum.format_bytes32_hex current_value}".htb,
        gas_limit: 250_000,
        to: contract.address,
      }).txid
    ensure
      return oracle.writes.create(txid: txid, value: current_value)
    end
  end


  private

  attr_reader :account, :contract, :oracle

  def write_address
    contract.write_address
  end

  def current_value
    @current_value ||= oracle.current_value.to_s[0..31]
  end

end
