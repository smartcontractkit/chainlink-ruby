FactoryGirl.define do

  factory :ethereum_formatted_oracle, class: Ethereum::FormattedOracle do
    body do
      hashie({
        address: (address.present? ? address : ethereum_address),
        updateAddress: (update_address.present? ? update_address : SecureRandom.hex),
      })
    end
  end

end
