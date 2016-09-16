def contract_json(options = {})
  attachments = options[:attachments] || []
  creator_id = options[:creator_id] || SecureRandom.hex
  creator_sig_key = SecureRandom.hex
  escrows = options[:escrows] || []
  id = options[:id] || SecureRandom.hex
  outcomes = if options[:outcomes] == true
    outcomes_json
  elsif options[:outcomes]
    options[:outcomes]
  else
    nil
  end
  signature_deadline = 1.day.from_now.to_i.to_s
  start_time = options[:start_time] || Time.now.to_i.to_s
  term_deadline = 1.week.from_now.to_i.to_s
  first_term = options[:term] || oracle_term_json({
    deadline: term_deadline,
    creator_id: creator_id,
    creator_sig_key: creator_sig_key,
    name: '1'
  })
  if options[:second_term] == true
    second_term = oracle_term_json({
      name: '2',
      creator_id: creator_id,
      creator_sig_key: creator_sig_key
    })
  end
  second_term ||= options[:second_term]

  {
    "contract": {
      "description": "dezy",
      "signature_deadline": signature_deadline,
      "escrows": escrows,
      "id": id,
      "name": "Human Ident",
      "signers": [{
        "signature_key": creator_sig_key,
        "xid": creator_id
      }],
      "terms": [first_term, second_term].compact,
      "type": "oracle",
      "attachments": attachments
    },
    "outcomes": outcomes,
    "privacy": "public",
    "source": "smartcontract.com",
    "start-time": start_time
  }.to_json
end

def term_json(options = {})
  name = options[:name] || '1'
  type = options[:type] || Validator.pluck(:type).sample
  {
    "success": {"actions": []},
    "failure": {"actions": []},
    "name": name,
    "expected": {
      "type": type,
      "deadline": 1.year.from_now.to_i.to_s
    }
  }
end

def custom_term_json(options = {})
  term_deadline = options[:deadline] || 1.week.from_now.to_i.to_s
  name = options[:name] || '1'
  comparison = options[:comparison] || '==='
  endpoint = options[:endpoint] || "https://www.#{Faker::Internet.domain_name}/api/recent"
  fields = options[:fields] || ['a', '0', 'b', '1']
  value = options[:value] || Random.rand(1_000.0)

  {
    "success": {"actions":[]},
    "failure": {"actions":[]},
    "name": name,
    "type": CustomExpectation::SCHEMA_NAME,
    "expected": {
      "type": CustomExpectation::SCHEMA_NAME,
      "comparison": comparison,
      "endpoint": endpoint,
      "deadline": term_deadline,
      "fields": fields,
      "value": value,
    }
  }
end

def oracle_term_json(options = {})
  term_deadline = options[:deadline] || 1.week.from_now.to_i.to_s
  name = options[:name] || '1'
  endpoint = options[:endpoint] || "https://www.#{Faker::Internet.domain_name}/api/recent"
  fields = options[:fields] || ['a', '0', 'b', '1']
  schedule = options[:schedule]

  {
    "success": {"actions":[]},
    "failure": {"actions":[]},
    "name": name,
    "type": EthereumOracle::SCHEMA_NAME,
    "expected": {
      "type": EthereumOracle::SCHEMA_NAME,
      "endpoint": endpoint,
      "deadline": term_deadline,
      "fields": fields,
      "schedule": schedule,
    }.compact
  }
end

def outcomes_json(options = {})
  failure_hex = options[:failure_hex] || SecureRandom.hex(256)
  success_hex = options[:success_hex] || SecureRandom.hex(256)

  {
    "1": {
      "failure": [failure_hex],
      "success": [success_hex]
    }
  }
end
