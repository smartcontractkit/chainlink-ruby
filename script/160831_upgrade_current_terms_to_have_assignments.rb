Term.where(expectation_type: 'CustomExpectation').pluck(:id).each do |id|
  term = Term.find(id)
  expectation = term.expectation
  next if expectation.blank?
  assignment = expectation.create_assignment!({
    parameters: {
      comparison: expectation.comparison,
      endpoint: expectation.endpoint,
      fields: expectation.fields,
      final_value: expectation.final_value,
      schedule_arguments: {
        hour: '*',
        minute: '0',
      }
    },
    end_at: [term.end_at, (term.created_at + 1)].max,
    start_at: term.created_at,
    status: term.status,
    term: term,
  })

  term.update_attributes!(expectation: assignment)
end

Term.where(expectation_type: 'EthereumOracle').pluck(:id).each do |id|
  term = Term.find(id)
  expectation = term.expectation
  assignment = expectation.create_assignment!({
    parameters: {
      endpoint: expectation.endpoint,
      fields: expectation.fields,
      schedule_arguments: {
        hour: '0',
        minute: '0',
      }
    },
    end_at: [term.end_at, (term.created_at + 1)].max,
    start_at: term.created_at,
    status: term.status,
    term: term,
  })

  term.update_attributes!(expectation: assignment)
end
