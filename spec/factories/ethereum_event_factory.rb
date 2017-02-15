FactoryGirl.define do

  factory :ethereum_event, class: Ethereum::Event do
    address { ethereum_address }
    block_hash { "0x#{ SecureRandom.hex 32 }" }
    block_number { rand(1_000_000) }
    log_index { rand(1_000_000) }
    association :log_subscription, factory: :ethereum_log_subscription
    transaction_hash { "0x#{ SecureRandom.hex 32 }" }
    transaction_index { rand(1_000_000) }
  end

end
