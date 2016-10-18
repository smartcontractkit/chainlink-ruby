class EthereumTransaction < ActiveRecord::Base

  belongs_to :account, class_name: 'EthereumAccount'

  validates :account, presence: true
  validates :txid, format: /\A0x[0-9a-f]{64}\z/

end
