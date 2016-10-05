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
    tx = account.send_transaction({
      data: "#{write_address}#{ethereum.format_bytes32_hex current_value}".htb,
      gas_limit: 100_000,
      to: contract.address,
    })

    if tx.persisted?
      oracle.writes.create txid: tx.txid, value: current_value
    else
      raise "Invalid Ethereum TX! \n\ntxid:#{tx.txid} \n\nhex:#{tx.raw_hex}"
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
