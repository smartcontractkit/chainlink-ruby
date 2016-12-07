class EthereumContractTemplate < ActiveRecord::Base

  validates :code, presence: true
  validates :construction_gas, numericality: { greater_than: 0 }
  validates :evm_hex, presence: true
  validates :json_abi, presence: true
  validates :read_address, presence: true
  validates :solidity_abi, presence: true
  validates :write_address, presence: true

  def self.default
    order(:created_at).last
  end

  def self.create_contract_template(contract_name = 'Oracle')
    code = File.read("lib/assets/contracts/#{contract_name}.sol")
    compiled = SolidityClient.compile code
    oracle = compiled['contracts'][contract_name]

    EthereumContractTemplate.create!({
      code: code,
      construction_gas: (oracle['gasEstimates']['creation'].last * 10),
      evm_hex: oracle['bytecode'],
      json_abi: oracle['interface'],
      read_address: oracle['functionHashes']['current()'],
      solidity_abi: SolidityClient.sol_abi(contract_name, oracle['interface']),
      write_address: oracle['functionHashes']['update(bytes32)'],
    })
  end

end
