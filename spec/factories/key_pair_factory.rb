FactoryGirl.define do

  factory :key_pair do
    association :owner, factory: :ethereum_account
  end

end
