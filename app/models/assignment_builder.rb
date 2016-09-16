class AssignmentBuilder

  def self.perform(coordinator, params)
    new(coordinator, params).perform
  end

  def initialize(coordinator, params)
    @params_body = params.with_indifferent_access
    @assignment = coordinator.assignments.build
  end

  def perform
    return assignment unless schema_fits?
    set_attributes
    assignment.save
    assignment
  end


  private

  attr_reader :assignment, :coordinator, :params_body

  def schema_fits?
    if schema.validate(params_body)
      true
    else
      schema.errors.each do |error|
        assignment.errors.add(:base, error)
      end
      false
    end
  end

  def set_attributes
    assignment.start_at = parse_time schedule[:startAt] || Time.now
    assignment.end_at = parse_time schedule[:endAt]
    assignment.parameters = assignment_body
    assignment.adapter = adapter_for assignment_params[:adapterType]
  end

  def assignment_body
    assignment_params[:adapterParams]
  end

  def assignment_params
    params_body[:assignment]
  end

  def schedule
    assignment_params[:schedule]
  end

  def parse_time(time)
    Time.at time.to_i
  end

  def adapter_for(type)
    if adapter = InputAdapter.for_type(type)
      adapter
    elsif [CustomExpectation::SCHEMA_NAME, 'custom'].include? type
      CustomExpectation.create(body: expectation_body)
    elsif [EthereumOracle::SCHEMA_NAME, 'oracle'].include? type
      EthereumOracle.create(body: expectation_body)
    else
      raise "no adapter type found for #{type}"
    end
  end

  def schema
    return @schema if @schema.present?
    json = File.read 'lib/assets/schemas/assignment_schema.json'
    @schema = SchemaValidator.new(json)
  end

end
