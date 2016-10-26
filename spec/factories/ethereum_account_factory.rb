FactoryGirl.define do

  factory :ethereum_account do
    address { "0x#{SecureRandom.hex 20}" }
  end

  factory :local_ethereum_account, parent: :ethereum_account do
    address { nil }
  end

end
