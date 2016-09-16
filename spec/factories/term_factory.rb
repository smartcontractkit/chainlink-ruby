FactoryGirl.define do

  sequence :name do |number|
    number.to_s
  end

  factory :term do
    contract
    end_at { (rand(365) + 1).days.from_now }
    name { generate(:name) }
    start_at { Time.now }
  end

end
