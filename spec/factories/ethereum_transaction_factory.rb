FactoryGirl.define do

  factory :ethereum_transaction do
    association :account, factory: :ethereum_account
    raw_hex do
      Eth::Tx.new({
        data: "0x#{SecureRandom.hex 32}",
        to: nil,
        value: 0,
        gas_price: 20_000,
        gas_limit: 100_000,
        nonce: rand(1_000_000),
      }).hex
    end
    txid { "0x#{SecureRandom.hex 32}" }
  end

end
