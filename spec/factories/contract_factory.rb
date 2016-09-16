FactoryGirl.define do

  factory :contract do
    json_body { { SecureRandom.base64 => SecureRandom.base64 } }
    xid { SecureRandom.hex }
  end

end
