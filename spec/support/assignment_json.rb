def assignment_json(options = {})
  adapter_params = options.fetch(:adapterParams, nil)
  adapter_type = options.fetch(:adapterType, assignment_types(:basic).name)
  description = options.fetch(:description, Faker::Lorem.paragraph)
  fees = options.fetch(:fees, nil)
  schedule = options.fetch(:schedule, {
    endAt: options.fetch(:endAt, 1.day.from_now).to_i.to_s,
    hour: options.fetch(:hour, '0'),
    minute: options.fetch(:minute, '0'),
    startAt: options[:startAt],
  }).compact
  signatures = options.fetch(:signatures, [])

  assignment = {
    adapterType: adapter_type,
    adapterParams: adapter_params,
    description: description,
    fees: fees,
    schedule: schedule,
  }.compact

  {
    assignment: assignment,
    assignmentHash: Digest::SHA256.digest(assignment.to_json),
    signatures: signatures,
    version: '0.1.0',
  }.compact.with_indifferent_access
end
