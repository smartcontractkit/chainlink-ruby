FactoryGirl.define do

  factory :ethereum_contract do
    association :account, factory: :local_ethereum_account
    association :template, factory: :ethereum_contract_template
  end

end
