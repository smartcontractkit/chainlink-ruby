FactoryGirl.define do

  sequence :subtask_index

  factory :subtask do
    association :adapter, factory: :external_adapter
    assignment
    index { generate(:subtask_index) }
  end

end
