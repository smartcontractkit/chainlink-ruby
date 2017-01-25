FactoryGirl.define do

  sequence :subtask_index

  factory :subtask do
    association :adapter, factory: :external_adapter
    assignment
    index { generate(:subtask_index) }
  end

  factory :uninitialized_subtask, parent: :subtask do
    after(:create) do |subtask|
      subtask.update_attributes ready: false
    end
  end

end
