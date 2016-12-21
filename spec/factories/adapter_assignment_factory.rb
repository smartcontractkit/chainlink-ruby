FactoryGirl.define do

  sequence :adapter_assignment_index

  factory :adapter_assignment do
    association :adapter, factory: :external_adapter
    assignment
    index { generate(:adapter_assignment_index) }
  end

end
