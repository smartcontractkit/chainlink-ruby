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
      end_at: parse_time(end_at),
      schedule_attributes: (schedule_params if schedule_params[:endAt]),
      scheduled_updates: (scheduled_updates if scheduled_updates.any?),
      skip_initial_snapshot: skip_initial_snapshot,
      start_at: parse_time(schedule_params[:startAt]),
    }.compact)
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

  def parse_time(time)
    Time.at time.to_i if time.present?
  end

  def schedule_params
    return @schedule_params if @scheduled_params.present?

    @schedule_params = @body[:schedule]
    @schedule_params ||= @body[:assignment] && @body[:assignment][:schedule]
    @schedule_params ||= {minute: '0', hour: '0'}
  end

  def subtask_params
    assignment_params[:subtasks] ||
      assignment_params[:pipeline] ||
      [assignment_params]
  end

  def subtasks
    @subtasks ||= subtask_params.map.with_index do |params, index|
      next unless params && type = params[:adapterType]
      adapter_params = params[:adapterParams] || assignment_body

      Subtask.new({
        adapter: AdapterBuilder.perform(type, adapter_params),
        index: index,
        parameters: adapter_params,
      })
    end
  end

  def end_at
    return @end_at if @end_at.present?
    times = Array.wrap(schedule_params[:runAt])
    times += [schedule_params[:endAt]]
    @end_at = times.compact.map(&:to_i).max
  end

  def scheduled_updates
    @scheduled_updates ||= Array.wrap(schedule_params[:runAt]).compact.map do |time|
      Assignment::ScheduledUpdate.new run_at: parse_time(time)
    end
  end

  def skip_initial_snapshot
    assignment_params[:skipInitialSnapshot]
  end

end
