class Coordinator < ActiveRecord::Base

  has_many :assignments

  validates :key, presence: true
  validates :secret, presence: true

  before_validation :generate_credentials, on: :create

  def create_assignment(assignment_params)
    AssignmentBuilder.perform self, assignment_params
  end


  private

  def generate_credentials
    self.key = SecureRandom.urlsafe_base64(32)
    self.secret = SecureRandom.urlsafe_base64(32)
  end

end
