FactoryGirl.define do

  factory :adapter_snapshot do
    subtask
    assignment_snapshot
  end

  factory :fulfilled_adapter_snapshot, parent: :adapter_snapshot do
    fulfilled { true }
  end

end
