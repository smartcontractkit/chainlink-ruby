FactoryGirl.define do

  factory :escrow_outcome do
    term
    result { [EscrowOutcome::FAILURE, EscrowOutcome::SUCCESS].sample }
    transaction_hex { [SecureRandom.hex] }
  end

end
