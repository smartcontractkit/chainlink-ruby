class AssignmentRequest < ActiveRecord::Base

  belongs_to :assignment, inverse_of: :request

  validates :assignment, presence: true
  validates :body_json, presence: true
  validates :body_hash, presence: true
  validates :signature, presence: true
  validate :matches_assignment_schema

  def body
    @body ||= JSON.parse(body_json)
  end


  private

  def matches_assignment_schema
    unless schema.validate body_json
      schema.errors.each {|error| errors.add :body_json, error }
    end if body_json.present?
  end

  def schema
    return @schema if @schema.present?
    json = File.read 'lib/assets/schemas/assignment_schema.json'
    @schema = SchemaValidator.new(json)
  end

end
