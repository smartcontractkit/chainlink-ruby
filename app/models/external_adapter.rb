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

  def start(assignment)
    client.start_assignment assignment
  end

  def get_status(status_record, details = {})
    client.assignment_snapshot status_record, details
  end

  def stop(assignment)
    client.stop_assignment assignment
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
