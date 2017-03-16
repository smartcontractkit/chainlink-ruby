class JsonReceiver < ActiveRecord::Base
  SCHEMA_NAME = 'jsonReceiver'

  include AdapterBase

  has_one :subtask, as: :adapter
  has_one :assignment, through: :subtask
  has_many :requests, inverse_of: :json_receiver

  validates :path, presence: true
  validate :parsable_path

  before_validation :set_up_from_body, on: :create

  def path=(path)
    path = Array.wrap(path)
    self.path_json = path.to_json
    self.path
  end

  def path
    JSON.parse(path_json) if path_json.present?
  end

  def get_status(snapshot, previous_snapshot)
    assignment_snapshot = snapshot.assignment_snapshot

    if assignment_snapshot.requester == subtask
      request = assignment_snapshot.request
      AssignmentSnapshot::JsonReceiverDecorator.new(request)
    elsif previous_snapshot.present?
      previous_snapshot
    else
      AssignmentSnapshot::NilDecorator.new
    end
  end

  private

  def set_up_from_body
    if body.present?
      self.path ||= body.path
    end
    self.xid ||= SecureRandom.urlsafe_base64(24)
  end

  def parsable_path
    if path.empty?
      errors.add(:path, 'must not be empty')
    elsif path.any?(&:blank?)
      errors.add(:path, 'must not have empty elements')
    end
  end

end
