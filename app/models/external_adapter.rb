class ExternalAdapter < ActiveRecord::Base

  include AdapterBase

  belongs_to :assignment_type
  has_many :subtasks, as: :adapter
  has_many :assignments, through: :subtasks

  validates :assignment_type, presence: true
  validates :url, presence: true

  before_validation :set_up, on: :create

  def self.for_type(type)
    joins(:assignment_type).where('assignment_types.name = ?', type).first
  end

  def type
    assignment_type.name
  end

  def start(subtask)
    client.start_assignment subtask
  end

  def get_status(snapshot, previous_snapshot = nil)
    assignment_snapshot = snapshot.assignment_snapshot

    if snapshot.subtask == assignment_snapshot.requester
      assignment_snapshot.request
    else
      client.assignment_snapshot snapshot, previous_snapshot
    end
  end

  def stop(subtask)
    client.stop_assignment subtask
  end

  def create_assignment(options = {})
    assignments.create(options)
  end

  def schema_errors_for(parameters)
    assignment_type.schema_errors_for parameters
  end

  def type_name
    assignment_type.name
  end


  private

  def client
    @client ||= ExternalAdapterClient.new(self)
  end

  def set_up
    self.password ||= SecureRandom.urlsafe_base64(64)
    self.username ||= SecureRandom.urlsafe_base64(64)
  end

end
