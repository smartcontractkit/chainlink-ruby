class EthereumContractTemplate < ActiveRecord::Base

  validates :adapter_name, presence: true
  validates :code, presence: true
  validates :construction_gas, numericality: { greater_than: 0 }
  validates :evm_hex, presence: true
  validates :json_abi, presence: true
  validates :read_address, presence: true
  validates :solidity_abi, presence: true
  validates :write_address, presence: true

  def self.for(type)
    find_by adapter_name: type
  end

  def self.create_contract_template(contract_name = 'Oracle', adapter_name = nil, type = "bytes32")
    code = File.read("lib/assets/contracts/#{contract_name}.sol")

    compiled = SolidityClient.compile({
      "#{contract_name}.sol" => code,
      "Owned.sol" => File.read("lib/assets/contracts/Owned.sol"),
    })
    oracle = compiled['contracts'][contract_name]

    EthereumContractTemplate.create!({
      adapter_name: (adapter_name || contract_name),
      code: code,
      construction_gas: (oracle['gasEstimates']['creation'].last * 10),
      evm_hex: oracle['bytecode'],
      json_abi: oracle['interface'],
      read_address: oracle['functionHashes']['current()'],
      solidity_abi: SolidityClient.sol_abi(contract_name, oracle['interface']),
      write_address: oracle['functionHashes']["update(#{type})"],
    })
  end

end
