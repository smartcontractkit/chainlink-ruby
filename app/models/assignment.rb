class Assignment < ActiveRecord::Base

  COMPLETED = 'completed'
  FAILED = 'failed'
  IN_PROGRESS = 'in progress'

  belongs_to :coordinator
  has_one :term, as: :expectation, inverse_of: :expectation
  has_one :request, class_name: 'AssignmentRequest', inverse_of: :assignment
  has_one :schedule, class_name: 'AssignmentSchedule', inverse_of: :assignment
  has_many :scheduled_updates, inverse_of: :assignment
  has_many :subtasks, inverse_of: :assignment
  has_many :snapshots, class_name: 'AssignmentSnapshot', inverse_of: :assignment

  validates :subtasks, presence: true
  validates :coordinator, presence: true
  validates :end_at, presence: true
  validates :start_at, presence: true
  validates :status, inclusion: { in: [COMPLETED, FAILED, IN_PROGRESS] }
  validate :associations_including_errors
  validate :start_at_before_end_at
  validate :finished_status_remains

  before_validation :set_up, on: :create
  after_create :set_initial_value, if: :ready?

  validates_associated :schedule
  accepts_nested_attributes_for :schedule

  def adapters
    subtasks.map(&:adapter)
  end

  def term_status
    term.status
  end

  def check_status(options = {})
    if ready?
      snapshots.create({
        request: options[:request],
        requester: options[:requester],
      })
    end
  end

  def close_out!(status = COMPLETED)
    subtasks.each(&:close_out!)

    update_status status
  end

  def update_status(new_status)
    updated_status = update_term_status(new_status)

    if updated_status && update_attributes(status: updated_status)
      snapshots.create({
        fulfilled: true,
        status: updated_status,
        summary: "#{name} is #{updated_status}.",
      })
    end
  end

  def name
    "Assignment \"#{term.try(:name) || request.try(:name) || xid}\""
  end

  def related_term
    term
  end

  def adapter_types
    subtasks.pluck(:adapter_type)
  end

  def subtask_ready(subtask)
    if ready? && subtasks.include?(subtask)
      check_status
      coordinator.assignment_initialized id
    end
  end

  def initialization_details
    subtasks.map(&:initialization_details)
  end


  private

  def set_up
    self.end_at ||= term.try(:end_at)
    self.start_at ||= [Time.now, end_at].compact.min
    self.status ||= IN_PROGRESS
    self.xid ||= SecureRandom.uuid
  end

  def start_at_before_end_at
    if end_at == Time.at(0)
      errors.add(:end_at, "must be specified")
    end

    if start_at.to_i > end_at.to_i
      errors.add(:start_at, "must be before end at")
    end
  end

  def update_term_status(new_status)
    if term.present?
      term.update_status new_status, false
    else
      new_status
    end
  end

  def finished_status_remains
    return if new_record?

    if changed.include?('status') && changed_attributes[:status] != IN_PROGRESS
      errors.add(:status, 'is no longer in progress')
    end
  end

  def associations_including_errors
    subtasks.each do |associated|
      associated.errors.full_messages.each do |message|
        errors[:base] << message
      end unless associated.valid?
    end
  end

  def ready?
    subtasks.all?(&:ready?)
  end

  def set_initial_value
    delay.check_status
  end

end
