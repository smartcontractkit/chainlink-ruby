class EthereumTransaction < ActiveRecord::Base

  include BinaryAndHex
  include HasEthereumClient

  belongs_to :account, class_name: 'EthereumAccount'

  validates :account, presence: true
  validates :txid, format: /\A0x[0-9a-f]{64}\z/

  before_validation :publish_to_blockchain, on: :create

  attr_accessor :raw_hex


  private

  def publish_to_blockchain
    return if txid.present? || raw_hex.blank?
    response = ethereum.send_raw_transaction(raw_hex)
    self.txid = response.txid
  end

end
