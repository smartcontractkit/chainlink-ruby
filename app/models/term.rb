class Term < ActiveRecord::Base

  COMPLETED = 'completed'
  FAILED = 'failed'
  IN_PROGRESS = 'in progress'

  belongs_to :contract, inverse_of: :terms
  belongs_to :expectation, polymorphic: true, inverse_of: :term
  has_one :failure_outcome,
    -> { where result: EscrowOutcome::FAILURE }, class_name: EscrowOutcome
  has_one :success_outcome,
    -> { where result: EscrowOutcome::SUCCESS }, class_name: EscrowOutcome

  validates :contract, presence: true
  validates :end_at, presence: true
  validates :expectation, presence: true
  validates :name, presence: true, uniqueness: { scope: :contract_id }
  validates :start_at, presence: true
  validates :status, inclusion: { in: [COMPLETED, FAILED, IN_PROGRESS] }
  validate :start_at_before_end_at
  validate :associations_including_errors
  validate :finished_status_remains

  before_validation :set_initial_values, on: :create

  scope :expired, -> { in_progress.where("end_at < (?)", Time.now) }
  scope :in_progress, -> { where("status = ?", IN_PROGRESS) }
  scope :remote, -> { type('Assignment') }
  scope :type, -> (type) { where("expectation_type = ?", type) }

  def completed?
    status == COMPLETED
  end

  def failed?
    status == FAILED
  end

  def in_progress?
    status == IN_PROGRESS
  end

  def unfinished?
    !(completed? || failed?)
  end

  def oracle?
    expectation_type == EthereumOracle.name ||
      (assignment? && expectation.adapter_types.include?(EthereumOracle.name))
  end

  def update_status(new_status, update_expectation = true)
    return status if new_status == status

    if unfinished? && update_attributes(status: new_status)
      contract.delay.check_status
      coordinator.update_term id
      expectation.delay.close_out! new_status if update_expectation
      new_status
    end
  end

  def contract_xid
    contract.xid
  end

  def outcome_signatures
    raise "No signatures, term is still in progress!" if in_progress?

    if final_outcome.present?
      final_outcome.signatures
    else
      []
    end
  end


  private

  def coordinator
    contract.coordinator
  end

  def final_outcome
    return success_outcome if completed?
    return failure_outcome if failed?
  end

  def set_initial_values
    self.status ||= IN_PROGRESS
  end

  def start_at_before_end_at
    if start_at.to_i >= end_at.to_i
      errors.add(:start_at, "must be before end at")
    end
  end

  def body
    @body ||= contract.term_body(name)
  end

  def associations_including_errors
    [expectation].compact.each do |associated|
      associated.errors.full_messages.each do |message|
        errors[:base] << "#{associated.class.to_s} Error: #{message}"
      end unless associated.valid?
    end
  end

  def finished_status_remains
    return if new_record?

    if changed.include?('status') && changed_attributes[:status] != IN_PROGRESS
      errors.add(:status, 'is no longer in progress')
    end
  end

  def assignment?
    expectation_type == Assignment.name
  end

end
