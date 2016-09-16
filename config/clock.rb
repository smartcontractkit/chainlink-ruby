require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  configure do |config|
    config[:max_threads] = 3
    config[:thread] = true
  end

  handler do |job|
    system "rails runner '#{job}'"
  end

  every(1.minute, 'AssignmentScheduler.perform')
  every(1.minute, 'TermJanitor.clean_up')
  every(1.minute, 'EthereumReceiptWatcher.perform')
  every(1.hour, 'EthereumBalanceChecker.perform')
end
