FactoryGirl.define do

  factory :assignment do
    parameters { { SecureRandom.base64 => SecureRandom.base64 } }
    association :adapter, factory: :input_adapter
    end_at { 1.month.from_now }
  end

  factory :completed_assignment, parent: :assignment do
    status { Assignment::COMPLETED }
  end

  factory :ethereum_assignment, parent: :assignment do
    association :adapter, factory: :ethereum_oracle
  end

  factory :failed_assignment, parent: :assignment do
    status { Assignment::FAILED }
  end

end
