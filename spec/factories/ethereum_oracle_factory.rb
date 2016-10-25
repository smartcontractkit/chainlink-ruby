FactoryGirl.define do

  factory :ethereum_oracle do
    endpoint { "https://#{Faker::Internet.domain_name}/api" }
    ethereum_contract
    fields { [SecureRandom.urlsafe_base64] }
  end

  factory :assigned_ethereum_oracle, parent: :ethereum_oracle do
    assignment
  end

end
