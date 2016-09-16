FactoryGirl.define do

  factory :bitcoin_transaction do
    txid { SecureRandom.hex }
    confirmations { rand(10) + 1 }
  end

end
