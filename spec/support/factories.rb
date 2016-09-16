def payment_factory(options = {})
  expectation = options[:payment_expectation] || payment_expectation_factory
  output = options[:bitcoin_output] || factory_create(:bitcoin_output)

  expectation.payments.create({
    bitcoin_output: output,
    bitcoin_transaction: output.bitcoin_transaction
  })
end

def term_factory(options = {})
  factory_create :term, options
end

def custom_term_factory(options = {})
  options[:contract] ||= custom_contract_factory
  term_factory options
end

def oracle_term_factory(options = {})
  oracle_contract_factory.terms.first.tap do |term|
    term.update_attributes options
  end
end

def contract_factory(options = {})
  status = options[:status] || Contract::IN_PROGRESS
  json_body = options[:json_body] || contract_json
  body = JSON.parse json_body

  ContractBuilder.perform(body).tap do |contract|
    contract.status = status
    contract.save if contract.persisted?
  end
end

def custom_contract_factory(options = {})
  options[:json_body] ||= contract_json term: custom_term_json
  contract_factory options
end

def oracle_contract_factory(options = {})
  options[:json_body] ||= contract_json term: oracle_term_json(options[:term_options] || {})
  contract_factory options
end

def escrow_outcome_factory(options = {})
  term = options[:term] || term_factory
  result = options[:result] || [EscrowOutcome::FAILURE, EscrowOutcome::SUCCESS].sample
  transaction_hex = options[:transaction_hex] || options[:transaction_hexes] || [SecureRandom.hex]

  EscrowOutcome.create({
    result: result,
    term: term,
    transaction_hexes: transaction_hex
  })
end
