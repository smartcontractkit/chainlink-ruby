module SpecHelpers

  def assignment_0_1_0_body(options = {})
    adapter_params = options.fetch(:adapterParams, nil)
    adapter_type = options.fetch(:adapterType, AssignmentType.first.name)
    description = options.fetch(:description, Faker::Lorem.paragraph)
    fees = options.fetch(:fees, nil)
    schedule = schedule_hash(options)

    {
      adapterType: adapter_type,
      adapterParams: adapter_params,
      description: description,
      fees: fees,
      schedule: schedule,
    }.compact
  end

  def assignment_0_1_0_hash(options = {})
    assignment = assignment_0_1_0_body(options)
    signatures = options.fetch(:signatures, [])

    {
      assignment: assignment,
      assignmentHash: options.fetch(:assignmentHash, Digest::SHA256.hexdigest(assignment.to_json)),
      signatures: signatures,
      version: '0.1.0',
    }.compact.with_indifferent_access
  end

  def assignment_0_1_0_json(options = {})
    assignment_0_1_0_hash(options).to_json
  end

  def assignment_1_0_0_body(options = {})
    input_params = options.fetch(:input_params, nil)
    input_type = options.fetch(:input_type, AssignmentType.first.name)
    output_params = options.fetch(:output_params, nil)
    output_type = options.fetch(:output_type, AssignmentType.second.name)

    description = options.fetch(:description, Faker::Lorem.paragraph)
    fees = options.fetch(:fees, nil)
    schedule = schedule_hash(options)
    subtasks = options.fetch(:subtasks, [
      {
        adapterType: input_type,
        adapterParams: input_params,
      }.compact,
      {
        adapterType: output_type,
        adapterParams: output_params,
      }.compact,
    ])

    {
      subtasks: subtasks,
      description: description,
      fees: fees,
      schedule: schedule,
    }.compact
  end

  def assignment_1_0_0_hash(options = {})
    assignment = assignment_1_0_0_body(options)
    signatures = options.fetch(:signatures, [])

    {
      assignment: assignment,
      assignmentHash: options.fetch(:assignmentHash, Digest::SHA256.hexdigest(assignment.to_json)),
      signatures: signatures,
      version: '1.0.0',
    }.compact.with_indifferent_access
  end

  def assignment_1_0_0_json(options = {})
    assignment_1_0_0_hash(options).to_json
  end

  def schedule_hash(options = {})
    options.fetch(:schedule, {
      endAt: options.fetch(:endAt, 1.day.from_now).to_i.to_s,
      hour: options.fetch(:hour, '0'),
      minute: options.fetch(:minute, '0'),
      startAt: options[:startAt],
    }).compact
  end

end
