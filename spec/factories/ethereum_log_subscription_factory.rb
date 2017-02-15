FactoryGirl.define do

  factory :ethereum_log_subscription, class: Ethereum::LogSubscription do
    account { ethereum_address }
    association :owner, factory: :ethereum_contract
    end_at { 1.year.from_now }
    xid { SecureRandom.uuid }
  end

end
