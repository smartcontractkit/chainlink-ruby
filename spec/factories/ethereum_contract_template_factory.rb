FactoryGirl.define do

  factory :ethereum_contract_template do
    code { SecureRandom.hex }
    construction_gas { 1_000_000 }
    evm_hex { SecureRandom.hex }
    json_abi { SecureRandom.hex }
    read_address { SecureRandom.hex }
    solidity_abi { SecureRandom.hex }
    write_address { SecureRandom.hex }
  end

end
