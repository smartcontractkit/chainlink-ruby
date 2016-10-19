FactoryGirl.define do

  factory :ethereum_transaction do
    association :account, factory: :ethereum_account
    raw_hex { "0x#{SecureRandom.hex 128}" }
    txid { "0x#{SecureRandom.hex 32}" }
  end

end
