FactoryGirl.define do

  factory :assignment_type do
    json_schema { { SecureRandom.base64 => SecureRandom.base64 }.to_json }
    name { Faker::Lorem.sentence }
  end

end
