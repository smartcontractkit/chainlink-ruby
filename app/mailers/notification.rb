class Notification < ActionMailer::Base

  default from: ENV['EMAIL_USERNAME']

  def ethereum_balance(account, balance)
    @account = account
    @balance = balance
    mail(to: notification_addresses, subject: "(#{Rails.env}) Low Ethereum balance alert!")
  end


  private

  def notification_addresses
    ENV['NOTIFICATION_EMAIL'].split(',').map(&:strip)
  end

end
