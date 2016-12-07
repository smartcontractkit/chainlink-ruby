class EthereumContract < ActiveRecord::Base

  belongs_to :account, class_name: 'Ethereum::Account'
  belongs_to :template, class_name: 'EthereumContractTemplate'
  belongs_to :genesis_transaction, class_name: 'EthereumTransaction'
  has_one :ethereum_oracle

  validates :account, presence: true
  validates :address, format: { with: /\A0x[0-9a-f]{40}\z/, allow_nil: true }
  validates :genesis_transaction, presence: true
  validates :template, presence: true

  before_validation :set_defaults, on: :create

  scope :unconfirmed,  -> { where address: nil }

  def confirmed(confirmed_address)
    update_attributes!({
      address: confirmed_address
    })

    ethereum_oracle.delay.check_status
    coordinator.oracle_instructions ethereum_oracle.id
  end

  def write_address
    template.write_address
  end

  def confirmed?
    address.present?
  end


  private

  def set_defaults
    self.account ||= Ethereum::Account.default
    self.template ||= EthereumContractTemplate.default

    self.genesis_transaction = account.send_transaction({
      data: template.evm_hex,
      gas_limit: 300_000,
    })
  end

  def coordinator
    ethereum_oracle.assignment.coordinator
  end

end
