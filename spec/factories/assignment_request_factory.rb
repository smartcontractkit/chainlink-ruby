FactoryGirl.define do

  factory :assignment_request do
    body_json { assignment_0_1_0_json }
    body_hash { SecureRandom.hex }
  end

end
