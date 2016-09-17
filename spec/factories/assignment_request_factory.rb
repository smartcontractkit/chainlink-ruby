FactoryGirl.define do

  factory :assignment_request do
    assignment
    body_json { assignment_json }
    body_hash { SecureRandom.hex }
  end

end
