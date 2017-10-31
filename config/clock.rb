require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork

  configure do |config|
    config[:max_threads] = 10
    config[:thread] = true
  end

  handler do |job|
    system "rails runner '#{job}'"
  end

  every(1.minute, 'AssignmentScheduler.perform')
  every(1.minute, 'Ethereum::ConfirmationWatcher.delay.perform')
  every(1.minute, 'Ethereum::ContractConfirmer.delay.perform')
  every(1.minute, 'TermJanitor.delay.clean_up')
  every(1.minute, 'Assignment::Janitor.delay.schedule_clean_up')

  every(1.hour, 'Ethereum::BalanceWatcher.delay.perform')

  if time = ENV['HEALTH_CHECK_TIME']
    every(1.day, 'HealthCheck.delay.perform', at: time)
  end
end
