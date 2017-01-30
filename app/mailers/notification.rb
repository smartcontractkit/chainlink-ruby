class Notification < ActionMailer::Base

  RECIPIENTS = ENV['NOTIFICATION_EMAIL'].to_s.split(',').map(&:strip)

  default from: ENV['EMAIL_USERNAME'], to: RECIPIENTS

  def ethereum_balance(account, balance)
    @account = account
    @balance = balance

    mail subject: "#{node_name}: Low Ethereum balance alert!"
  end

  def snapshot_failure(assignment, errors)
    @assignment = assignment
    @errors = errors

    mail subject: "#{node_name}: snapshot failure"
  end

  def health_check
    @check = HealthCheck.new
    subject = "Health Check: #{@check.status} #{Date.today.to_s}(#{node_name})"

    mail subject: subject
  end


  private

  def node_name
    ENV['NODE_NAME'] || Rails.env
  end

end
