FactoryGirl.define do

  factory :ethereum_bytes32_oracle, class: Ethereum::Bytes32Oracle do
    body do
      hashie({
        address: (address.present? ? address : ethereum_address),
        update_address: (update_address.present? ? update_address : SecureRandom.hex),
      })
    end
  end

end
