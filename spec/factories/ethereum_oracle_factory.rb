FactoryGirl.define do

  factory :ethereum_oracle do
    body do
      hashie({
        endpoint: (endpoint.present? ? endpoint : "https://#{Faker::Internet.domain_name}/api"),
        fields: (fields.present? ? fields : [SecureRandom.urlsafe_base64]),
      })
    end

    after(:create) do |oracle|
      oracle.ethereum_contract(true)
    end
  end

  factory :assigned_ethereum_oracle, parent: :ethereum_oracle do
    adapter_assignment
  end

end
