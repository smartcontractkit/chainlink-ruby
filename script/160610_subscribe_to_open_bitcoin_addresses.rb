BitcoinAddress.update_all(bcy_id: nil)

terms = Term.where({
  expectation_type: 'PaymentExpectation',
  status: Term::IN_PROGRESS,
})

terms.map(&:expectation).each do |expectation|
  expectation.bitcoin_address.delay.subscribe expectation
end
