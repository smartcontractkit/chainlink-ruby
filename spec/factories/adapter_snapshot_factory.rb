FactoryGirl.define do

  factory :adapter_snapshot do
    adapter_assignment
    assignment_snapshot
  end

  factory :fulfilled_adapter_snapshot, parent: :adapter_snapshot do
    fulfilled { true }
  end

end
