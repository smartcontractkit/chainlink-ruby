FactoryGirl.define do

  factory :custom_expectation do
    comparison { ['===', '<', '>', 'contains'].sample }
    endpoint { "https:''#{Faker::Internet.domain_name}/api/" }
    fields { ['recent', '0'] }
    final_value { '100' }
  end

end
