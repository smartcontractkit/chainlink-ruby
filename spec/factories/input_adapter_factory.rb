FactoryGirl.define do

  factory :input_adapter do
    assignment_type
    url { Faker::Internet.domain_name }
  end

end
