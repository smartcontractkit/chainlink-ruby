FactoryGirl.define do

  factory :json_receiver do
    body do
      Hashie::Mash.new({
        path: ['value']
      })
    end
  end

end
