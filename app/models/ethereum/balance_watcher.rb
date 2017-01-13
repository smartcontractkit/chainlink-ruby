class Ethereum::BalanceWatcher

  include HasEthereumClient

  def self.perform
    new(ENV['ETHEREUM_ACCOUNT']).perform
  end

  def initialize(account)
    @account = account
  end

  def perform
    balance = ethereum.account_balance account
    if balance <= minimum_balance
      Notification.ethereum_balance(account, balance).deliver_now
    end
  end


  private

  attr_reader :account

  def minimum_balance
    (ENV['ETHEREUM_MINIMUM_BALANCE'] || Ethereum::WEI_PER_ETHER).to_i
  end

end
