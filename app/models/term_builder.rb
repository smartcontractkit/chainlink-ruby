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
    @end_at ||= Time.at body.expected.deadline.to_i
  end

  def outcome_for(result, outcome_body)
    EscrowOutcome.new({
      result: result,
      transaction_hexes: outcome_body[result]
    }) if outcome_body.present?
  end

  def assignment_request
    @assignment_request ||= AssignmentRequest.create({
      coordinator: coordinator,
      body_json: {
        assignment: assignment_hash,
        assignmentHash: Digest::SHA256.hexdigest(assignment_hash.to_json),
        schedule: schedule,
        signatures: [],
        version: '0.1.0'
      }.to_json
    })
  end

  def assignment_hash
    {
      adapterParams: body.expected,
      adapterType: type,
      schedule: schedule.merge({
        endAt: end_at.to_i.to_s,
        startAt: start_time.to_i.to_s,
      }),
    }
  end

  def expectation
    assignment_request.assignment
  end

  def determine_schedule
    return @schedule if @schedule.present?

    @schedule = expectation_body.delete(:schedule)
    @schedule ||= {
      hour: ([CustomExpectation::SCHEMA_NAME, 'custom'].include?(type) ? '*' : '0'),
      minute: '0',
    }
    @schedule[:endAt] ||= end_at.to_i.to_s
    @schedule
  end

end
