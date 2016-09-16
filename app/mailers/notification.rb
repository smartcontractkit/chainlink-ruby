class Notification < ActionMailer::Base

  default from: 'notifications@smartcontract.com'

  def ethereum_balance(account, balance)
    @account = account
    @balance = balance
    mail(to: ['team@smartcontract.com'], subject: "(#{Rails.env}) Low Ethereum balance alert!")
  end

end
