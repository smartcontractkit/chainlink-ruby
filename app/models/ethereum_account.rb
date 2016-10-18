class EthereumAccount < ActiveRecord::Base

  include BinaryAndHex
  include HasEthereumClient

  has_one :key_pair, as: :owner
  has_many :ethereum_transactions, foreign_key: :account_id

  validates :address, format: /\A0x[0-9a-f]{40}\z/, uniqueness: true

  def self.default
    find_by address: ENV['ETHEREUM_ACCOUNT']
  end

  def sign(tx)
    return if key_pair.blank?
    tx.sign key_pair.ethereum_key
  end

  def next_nonce
    if database_nonce = ethereum_transactions.maximum(:nonce)
      database_nonce + 1
    else
      ethereum.get_transaction_count address
    end
  end

  def send_transaction(params)
    tx = build_signed_transaction params
    update_attributes nonce: (tx.nonce + 1)
    ethereum_transactions.create raw_hex: bin_to_hex(tx.encoded)
  end

  def sign_hash(hash)
    key_pair.ethereum_key.sign_hash hash
  end

  def public_key
    key_pair.uncompressed_public_key
  end


  private

  def build_signed_transaction(params)
    Eth::Tx.new({
      data: '',
      gas_price: ethereum.gas_price.to_i + 5000000000,
      nonce: next_nonce,
      value: 0,
    }.merge(params)).tap do |tx|
      tx.sign key_pair.ethereum_key
    end
  end

end
