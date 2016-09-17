class AssignmentRequest < ActiveRecord::Base

  include BinaryAndHex

  belongs_to :assignment, inverse_of: :request

  validates :assignment, presence: true
  validates :body_json, presence: true
  validates :body_hash, presence: true
  validates :signature, presence: true
  validate :matches_assignment_schema

  before_validation :sign_hash, on: :create

  def body
    @body ||= JSON.parse(body_json)
  end


  private

  def ethereum_account
    EthereumAccount.default
  end

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

  def sign_hash
    return if body_hash.blank?

    hash = hex_to_bin(body_hash)
    self.signature = bin_to_hex(ethereum_account.sign_hash hash)
  end

end
