class EthereumTransaction < ActiveRecord::Base

  belongs_to :account, class_name: 'EthereumAccount'

  validates :account, presence: true
  validates :txid, format: /\A0x[0-9a-f]{64}\z/

  scope :unconfirmed, -> { where "confirmations = 0 OR confirmations IS null" }

  def confirmed?
    confirmations.to_i > 0
  end

end
