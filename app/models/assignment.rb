class Assignment < ActiveRecord::Base

  COMPLETED = 'completed'
  FAILED = 'failed'
  IN_PROGRESS = 'in progress'

  belongs_to :adapter, polymorphic: true
  belongs_to :coordinator
  has_one :term, as: :expectation, inverse_of: :expectation
  has_one :request, class_name: 'AssignmentRequest', inverse_of: :assignment
  has_one :schedule, class_name: 'AssignmentSchedule', inverse_of: :assignment
  has_many :snapshots, class_name: 'AssignmentSnapshot', inverse_of: :assignment

  validates :adapter, presence: true
  validates :end_at, presence: true
  validates :start_at, presence: true
  validates :status, inclusion: { in: [COMPLETED, FAILED, IN_PROGRESS] }
  validate :start_at_before_end_at
  validate :valid_schema_parameters

  before_validation :set_up, on: :create
  before_validation :start_tracking, on: :create, if: :adapter

  validates_associated :schedule
  accepts_nested_attributes_for :schedule

  def parameters
    JSON.parse(json_parameters) if json_parameters.present?
  end

  def parameters=(new_parameters)
    return if new_parameters.nil?

    self.json_parameters = new_parameters.to_json
    self.parameters
  end

  def term_status
    term.status
  end

  def check_status
    snapshots.create
  end

  def close_out!
    adapter.stop self
  end

  def update_status(status)
    if term.update_status(status) && update_attributes(status: status)
      snapshots.create({
        fulfilled: true,
        status: status,
        summary: "#{name} is #{status}.",
      })
    end
  end

  def name
    "Assignment \"#{term.name}\""
  end

  def related_term
    term
  end


  private

  def type
    adapter.assignment_type
  end

  def set_up
    self.end_at ||= term.try(:end_at)
    self.start_at ||= Time.now
    self.status ||= IN_PROGRESS
    self.xid = SecureRandom.uuid
  end

  def start_tracking
    response = adapter.start self

    if response.errors.present?
      response.errors.each do |error_message|
        errors.add(:base, "Adapter: #{error_message}")
      end
    end
  end

  def valid_schema_parameters
    return unless valid_json_parameters?

    adapter.schema_errors_for(parameters).each do |error|
      errors.add(:base, error)
    end if adapter.present?
  end

  def valid_json_parameters?
    begin
      parameters
    rescue JSON::ParserError
      errors.add(:json_parameters, "are not valid JSON")
      false
    end
  end

  def start_at_before_end_at
    if start_at.to_i >= end_at.to_i
      errors.add(:start_at, "must be before end at")
    end
  end

end
