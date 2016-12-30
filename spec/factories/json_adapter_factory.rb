FactoryGirl.define do

  factory :json_adapter do
    body do
      hashie({
        url: (url.present? ? url : "https://#{Faker::Internet.domain_name}/api"),
        fields: (fields.present? ? fields : [SecureRandom.urlsafe_base64]),
      })
    end
  end

end
