FactoryGirl.define do

  factory :assignment_snapshot do
    assignment
    summary { Faker::Company.bs }
  end

  factory :unfulfilled_snapshot, parent: :assignment_snapshot do
    fulfilled { false }
  end

end
