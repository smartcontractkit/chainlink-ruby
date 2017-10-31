class Ethereum::BalanceWatcher

  include HasEthereumClient

  def self.perform(address = nil)
    Ethereum::Account.current.pluck(:address).each do |address|
      new(address).perform
    end
  end

  def initialize(address)
    @address = address
  end

  def perform
    balance = ethereum.account_balance address
    if balance <= minimum_balance
      Notification.ethereum_balance(address, balance).deliver_now
    end
  end


  private

  attr_reader :address

  def minimum_balance
    (ENV['ETHEREUM_MINIMUM_BALANCE'] || Ethereum::WEI_PER_ETHER).to_i
  end

end
