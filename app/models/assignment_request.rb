class AssignmentRequest < ActiveRecord::Base

  include BinaryAndHex

  belongs_to :assignment, inverse_of: :request

  validates :assignment, presence: true
  validates :body_json, presence: true
  validates :body_hash, presence: true
  validates :signature, presence: true
  validate :matches_assignment_schema

  before_validation :set_up_assignment, on: :create
  before_validation :sign_hash, on: :create

  validates_associated :assignment

  attr_writer :coordinator

  def body
    return @body if @body.present?
    @body = JSON.parse(body_json).with_indifferent_access if body_json.present?
  end

  def coordinator
    @coordinator ||= assignment.try(:coordinator)
  end

  def name
    body[:name]
  end


  private

  def set_up_assignment
    return unless body.present?

    self.assignment ||= build_assignment({
      subtasks: subtasks,
      coordinator: coordinator,
      end_at: parse_time(schedule[:endAt]),
      schedule_attributes: schedule_params,
      start_at: parse_time(schedule[:startAt] || Time.now),
    })
  end

  def sign_hash
    return unless body.present?

    hash = hex_to_bin(body_hash)
    self.signature = bin_to_hex(ethereum_account.sign_hash hash)
  end

  def ethereum_account
    Ethereum::Account.default
  end

  def matches_assignment_schema
    if schema.present?
      unless schema.validate body_json
        schema.errors.each {|error| errors.add :body_json, error }
      end
    else
      errors.add :body_json, "invalid assignment version"
    end
  end

  def schema
    @schema ||= SchemaValidator.version(body['version']) if body_json.present?
  end

  def assignment_body
    assignment_params[:adapterParams]
  end

  def assignment_params
    body[:assignment]
  end

  def schedule
    assignment_params[:schedule] if assignment_params.present?
  end

  def parse_time(time)
    Time.at time.to_i
  end

  def build_adapter(params)
    return unless params && type = params[:adapterType]

    adapter_params = params[:adapterParams] || assignment_body
    if adapter = ExternalAdapter.for_type(type)
      adapter
    elsif [CustomExpectation::SCHEMA_NAME, 'custom'].include? type
      CustomExpectation.new(body: adapter_params)
    elsif [EthereumOracle::SCHEMA_NAME, 'oracle'].include? type
      EthereumOracle.new(body: adapter_params)
    elsif [JsonAdapter::SCHEMA_NAME].include? type
      JsonAdapter.new(body: adapter_params)
    elsif [Ethereum::Bytes32Oracle::SCHEMA_NAME].include? type
      Ethereum::Bytes32Oracle.new(body: adapter_params)
    else
      raise "no adapter type found for #{type}"
    end
  end

  def schedule_params
    @schedule_params ||= (@body[:schedule] || {minute: '0', hour: '0'})
  end

  def subtask_params
    assignment_params[:subtasks] ||
      assignment_params[:pipeline] ||
      [assignment_params]
  end

  def subtasks
    @subtasks ||= subtask_params.map.with_index do |adapter_params, index|
      Subtask.new({
        adapter: build_adapter(adapter_params),
        index: index,
        parameters: adapter_params[:adapterParams],
      })
    end
  end

end
