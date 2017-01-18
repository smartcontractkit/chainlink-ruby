FactoryGirl.define do

  factory :assignment do
    subtasks { [factory_build(:subtask, assignment: nil)] }
    end_at { 1.month.from_now }
    coordinator
  end

  factory :completed_assignment, parent: :assignment do
    status { Assignment::COMPLETED }
  end

  factory :ethereum_assignment, parent: :assignment do
    subtasks do
      [factory_build(:subtask, {
        adapter: factory_build(:ethereum_oracle),
        assignment: nil,
      })]
    end
  end

  factory :failed_assignment, parent: :assignment do
    status { Assignment::FAILED }
  end

end
