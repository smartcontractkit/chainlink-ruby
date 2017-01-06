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

  def update_term(term_id)
    client.delay.update_term term_id if url?
  end

  def oracle_instructions(contract_id)
    client.delay.oracle_instructions contract_id if url?
  end

  def snapshot(snapshot_id)
    client.delay.snapshot snapshot_id if url?
  end


  private

  def generate_credentials
    self.key = SecureRandom.urlsafe_base64(32)
    self.secret = SecureRandom.urlsafe_base64(32)
  end

  def client
    @client ||= CoordinatorClient.new(self)
  end

  def url?
    url.present?
  end

end
