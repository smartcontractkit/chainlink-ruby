class ContractBuilder

  def self.perform(contract_body, coordinator)
    new(contract_body, coordinator).perform
  end

  def initialize(contract_body, coordinator)
    @coordinator = coordinator
    @json_body = contract_body.to_json
    @contract = @coordinator.contracts.new({
      json_body: json_body
    })
    @body = Hashie::Mash.new(contract_body)
    @agreement = body.contract
  end

  def perform
    setup_contract
    begin
      setup_terms
      contract.save! if valid_contract?
      contract
    rescue Exception => error
      contract.errors.add(:base, error.to_s)
      contract
    end
  end


  private

  attr_reader :agreement, :body, :contract, :coordinator, :json_body

  def setup_contract
    return unless agreement.present?

    contract.xid ||= agreement.id
    contract.status ||= Contract::IN_PROGRESS
  end

  def valid_contract?
    contract.valid?

    schema_validator.validate json_body
    schema_validator.errors.each do |error|
      contract.errors.add(:base, error)
    end

    contract.errors.blank?
  end

  def setup_terms
    return unless agreement.present? && agreement.terms.any?

    agreement.terms.each do |term_body|
      outcomes = outcomes_for(term_body.name)
      term = TermBuilder.perform(term_body, outcomes, start_time, coordinator)
      contract.terms += [term]
    end
  end

  def start_time
    @start_time ||= Time.at body['start-time'].to_i
  end

  def outcomes_for(name)
    return unless outcomes = body.outcomes
    key_value = outcomes.detect { |key, value| key == name }
    key_value.second if key_value.present?
  end

  def schema_validator
    return @schema_validator if @schema_validator.present?
    schema = JSON.parse(File.read 'lib/assets/schemas/contract_schema.json')
    @schema_validator = SchemaValidator.new(schema)
  end

end
