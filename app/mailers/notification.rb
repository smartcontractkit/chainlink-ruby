class Notification < ActionMailer::Base

  RECIPIENTS = ENV['NOTIFICATION_EMAIL'].to_s.split(',').map(&:strip)

  default from: ENV['EMAIL_USERNAME'], to: RECIPIENTS

  def ethereum_balance(account, balance)
    @account = account
    @balance = balance

    mail subject: "(#{Rails.env}) Low Ethereum balance alert!"
  end

  def snapshot_failure(assignment, errors)
    @assignment = assignment
    @errors = errors

    mail subject: "#{node_name}: snapshot failure"
  end


  private

  def node_name
    ENV['NODE_NAME']
  end

end
