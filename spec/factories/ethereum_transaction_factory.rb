FactoryGirl.define do

  factory :ethereum_transaction do
    association :account, factory: :ethereum_account
    txid { "0x#{SecureRandom.hex 32}" }
  end

end
