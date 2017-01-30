FactoryGirl.define do

  factory :external_adapter do
    assignment_type
    url { Faker::Internet.domain_name }
  end

end
