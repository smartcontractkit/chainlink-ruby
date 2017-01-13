FactoryGirl.define do

  factory :assignment do
    adapter_assignments { [factory_build(:adapter_assignment, assignment: nil)] }
    end_at { 1.month.from_now }
    coordinator
  end

  factory :completed_assignment, parent: :assignment do
    status { Assignment::COMPLETED }
  end

  factory :ethereum_assignment, parent: :assignment do
    adapter_assignments do
      [factory_build(:adapter_assignment, {
        adapter: factory_build(:ethereum_oracle),
        assignment: nil,
      })]
    end
  end

  factory :failed_assignment, parent: :assignment do
    status { Assignment::FAILED }
  end

end
