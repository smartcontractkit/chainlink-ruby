class EthereumContract < ActiveRecord::Base

  belongs_to :account, class_name: 'Ethereum::Account'
  belongs_to :genesis_transaction, class_name: 'EthereumTransaction'
  belongs_to :owner, polymorphic: true
  belongs_to :template, class_name: 'EthereumContractTemplate'
  has_many :log_subscriptions, as: :owner, class_name: 'Ethereum::LogSubscription'

  validates :account, presence: true
  validates :address, format: { with: /\A0x[0-9a-f]{40}\z/, allow_nil: true }
  validates :genesis_transaction, presence: true
  validates :template, presence: true

  before_validation :set_defaults, on: :create

  scope :unconfirmed,  -> { where address: nil }

  attr_accessor :adapter_type

  def confirmed(confirmed_address)
    update_attributes!({
      address: confirmed_address
    })

    owner.contract_confirmed confirmed_address
    delay.subscribe_to_contract_notifications
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
    self.template ||= EthereumContractTemplate.for adapter_type

    self.genesis_transaction = account.send_transaction({
      data: template.evm_hex,
      gas_limit: 300_000,
    })
  end

  def coordinator
    owner.coordinator
  end

  def subscribe_to_contract_notifications
    log_subscriptions.create({
      account: address,
      end_at: owner.end_at
    }) if template.use_logs?
  end

end
