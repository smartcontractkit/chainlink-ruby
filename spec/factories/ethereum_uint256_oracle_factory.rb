FactoryGirl.define do

  factory :ethereum_uint256_oracle, class: Ethereum::Uint256Oracle

  factory :external_uint256_oracle, parent: :ethereum_uint256_oracle do
    body do
      hashie({
        address: (address.present? ? address : ethereum_address),
        updateAddress: (update_address.present? ? update_address : SecureRandom.hex),
      })
    end
  end

end
