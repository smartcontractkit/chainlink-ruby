class EscrowOutcome < ActiveRecord::Base

  include HasBitcoinClient

  DELIMITER = "|||"
  FAILURE = 'failure'
  SUCCESS = 'success'

  belongs_to :term

  validates :result, inclusion: { in: [FAILURE, SUCCESS] }
  validates :term, presence: true, on: :update
  validates :transaction_hex, presence: true

  def transaction_hexes
    if transaction_hex.present?
      transaction_hex.split(DELIMITER)
    end
  end

  def transaction_hexes=(hexes)
    hexes = Array.wrap(hexes)
    self.transaction_hex = hexes.join(DELIMITER)
    transaction_hexes
  end

  def signatures
    transaction_hexes.map do |hex|
      key = KeyPair.key_for_tx hex
      bitcoin.signatures_for(hex, key)
    end
  end

end
