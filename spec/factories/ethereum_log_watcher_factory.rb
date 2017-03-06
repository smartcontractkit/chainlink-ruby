FactoryGirl.define do

  factory :ethereum_log_watcher, class: Ethereum::LogWatcher do
    body do
      hashie({
        address: (address.present? ? address : ethereum_address),
      })
    end
  end

end
