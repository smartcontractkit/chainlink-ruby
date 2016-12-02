class Coordinator < ActiveRecord::Base
  URL_REGEXP = File.read 'lib/assets/custom_uri_regexp.txt'

  has_many :assignments
  has_many :contracts

  validates :key, presence: true
  validates :secret, presence: true
  validates :url, format: { with: /\A#{URL_REGEXP}\z/x, allow_blank: true }

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
