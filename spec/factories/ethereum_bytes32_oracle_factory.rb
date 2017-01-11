FactoryGirl.define do

  factory :ethereum_bytes32_oracle, class: Ethereum::Bytes32Oracle

  factory :external_bytes32_oracle, parent: :ethereum_bytes32_oracle do
    body do
      hashie({
        address: (address.present? ? address : ethereum_address),
        updateAddress: (update_address.present? ? update_address : SecureRandom.hex),
      })
    end
  end

end
