class Contract < ActiveRecord::Base

  COMPLETED = 'completed'
  FAILED = 'failed'
  IN_PROGRESS = 'in progress'

  belongs_to :coordinator
  has_many :terms, inverse_of: :contract

  validates :json_body, presence: true
  validates :status, inclusion: { in: [COMPLETED, FAILED, IN_PROGRESS] }
  validates :xid, presence: true
  validate :associations_including_errors

  before_validation :set_status, on: :create
  after_create :publish_contract

  def term_body(name)
    agreement.terms.detect { |term| term.name == name }
  end

  def check_status
    return unless in_progress?
    if terms.any?(&:failed?)
      update_status FAILED
    elsif terms.all?(&:completed?)
      update_status COMPLETED
    end
  end

  def in_progress?
    status == IN_PROGRESS
  end

  def completeness
    (terms.select(&:completed?).size / terms.size.to_f).round(3)
  end


  private

  def update_status(new_status)
    update_attributes status: new_status
  end

  def body
    @body ||= Hashie::Mash.new JSON.parse(json_body)
  end

  def agreement
    body.contract
  end

  def set_status
    self.status ||= IN_PROGRESS
  end

  def publish_contract
    nil
  end

  def associations_including_errors
    terms.each do |term|
      term.errors.full_messages.each do |message|
        errors[:base] << "Term Error: #{message}"
      end unless term.valid?
    end
  end

end
