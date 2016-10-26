class TermBuilder

  def self.perform(body, outcomes, start_time, coordinator)
    new(body, outcomes, start_time, coordinator).perform
  end

  def initialize(body, outcomes, start_time, coordinator)
    @body = body
    @expectation_body = body.expected
    @outcomes = outcomes
    @start_time = start_time
    @type = expectation_body.type
    @coordinator = coordinator
    determine_schedule
    determine_adapter
  end

  def perform
    Term.new({
      end_at: end_at,
      expectation: expectation,
      failure_outcome: outcome_for('failure', outcomes),
      name: body.name,
      start_at: start_time,
      success_outcome: outcome_for('success', outcomes),
      tracking: body.type
    })
  end


  private

  attr_reader :adapter, :body, :coordinator, :expectation_body,
    :outcomes, :schedule, :start_time, :type

  def end_at
    Time.at body.expected.deadline.to_i
  end

  def outcome_for(result, outcome_body)
    EscrowOutcome.new({
      result: result,
      transaction_hexes: outcome_body[result]
    }) if outcome_body.present?
  end

  def expectation
    if adapter.valid? && adapter.persisted?
      adapter.create_assignment({
        coordinator: coordinator,
        end_at: end_at,
        parameters: expectation_body,
        schedule_attributes: schedule,
      }.compact)
    else
      adapter
    end
  end

  def determine_adapter
    if @adapter = InputAdapter.for_type(type)
      adapter
    elsif [CustomExpectation::SCHEMA_NAME, 'custom'].include? type
      @adapter = CustomExpectation.create(body: expectation_body)
    elsif [EthereumOracle::SCHEMA_NAME, 'oracle'].include? type
      @adapter = EthereumOracle.create(body: expectation_body)
    else
      raise "no term type specified for Term##{body.name}"
    end
  end

  def determine_schedule
    return @schedule if @schedule = expectation_body.delete(:schedule)

    if [CustomExpectation::SCHEMA_NAME, 'custom'].include? type
      @schedule = {minute: '0', hour: '*'}
    else
      @schedule = {minute: '0', hour: '0'}
    end
  end

end
