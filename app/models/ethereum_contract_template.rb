class EthereumContractTemplate < ActiveRecord::Base

  validates :code, presence: true
  validates :construction_gas, numericality: { greater_than: 0 }
  validates :evm_hex, presence: true
  validates :json_abi, presence: true
  validates :read_address, presence: true
  validates :solidity_abi, presence: true
  validates :write_address, presence: true

  def self.default
    last
  end

end
