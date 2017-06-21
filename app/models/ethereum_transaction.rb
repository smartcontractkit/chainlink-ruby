class EthereumTransaction < ActiveRecord::Base

  include HasEthereumClient

  belongs_to :account, class_name: 'Ethereum::Account'

  validates :account, presence: true
  validates :txid, format: /\A0x[0-9a-f]{64}\z/

  scope :unconfirmed, -> { where "confirmations = 0 OR confirmations IS null" }

  def confirmed?
    confirmations.to_i > 0
  end

  def tx
    Eth::Tx.decode raw_hex
  end

  def unconfirmed_update!(params)
    return false if confirmed?

    new_tx = updated_tx(params)
    ethereum.send_raw_transaction new_tx.hex
    record_new_tx_updates new_tx
    save!
  end

  private

  def updated_tx(params)
    tx.tap do |tx|
      tx.make_mutable!

      tx.gas_limit = params[:gas_limit] if params[:gas_limit].present?
      tx.gas_price = params[:gas_price] if params[:gas_price].present?
      tx.nonce = params[:nonce] if params[:nonce].present?
      account.sign tx
    end
  end

  def record_new_tx_updates(new_tx)
    self.gas_limit = new_tx.gas_limit
    self.gas_price = new_tx.gas_price
    self.nonce = new_tx.nonce
    self.txid = new_tx.id
    self.raw_hex = new_tx.hex
  end

end
