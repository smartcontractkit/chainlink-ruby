FactoryGirl.define do

  factory :ethereum_int256_oracle, class: Ethereum::Int256Oracle

  factory :external_int256_oracle, parent: :ethereum_int256_oracle do
    body do
      hashie({
        address: (address.present? ? address : ethereum_address),
        updateAddress: (update_address.present? ? update_address : SecureRandom.hex),
      }.compact)
    end
  end

end
