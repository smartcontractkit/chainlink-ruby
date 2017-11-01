class AssignmentRequest < ActiveRecord::Base

  include BinaryAndHex

  belongs_to :assignment, inverse_of: :request

  validates :assignment, presence: true
  validates :body_hash, presence: true
  validates :body_json, presence: true
  validates :signature, presence: true
  validate :matches_assignment_schema

  before_validation :set_up_assignment, on: :create
  before_validation :sign_hash, on: :create

  validates_associated :assignment

  attr_accessor :coordinator

  def body
    return @body if @body.present?
    @body = JSON.parse(body_json).with_indifferent_access if body_json.present?
  end

  def coordinator
    @coordinator ||= assignment.try(:coordinator)
  end

  def name
    body[:name]
  end

  def subtask_params
    assignment_params[:subtasks] ||
      assignment_params[:pipeline] ||
      [assignment_params]
  end

  def assignment_params
    body[:assignment]
  end

  def adapter_params
    assignment_params[:adapterParams]
  end


  private

  def set_up_assignment
    return unless body.present?
    if handler.valid?
      self.assignment ||= handler.assignment
    else
      handler.errors.each do |error|
        errors[:base] << error
      end
    end
  end

  def sign_hash
    return unless body.present?
    self.body_hash ||= Digest::SHA256.hexdigest(body_json)
    hash = hex_to_bin(body_hash)
    self.signature = bin_to_hex(ethereum_account.sign_hash hash)
  end

  def ethereum_account
    Ethereum::Account.default
  end

  def matches_assignment_schema
    if schema.present?
      unless schema.validate body_json
        schema.errors.each {|error| errors.add :body_json, error }
      end
    else
      errors.add :body_json, "invalid assignment version"
    end
  end

  def schema
    @schema ||= SchemaValidator.version(body['version']) if body_json.present?
  end

  def handler
    @handler ||= Assignment::RequestHandler.perform(self)
  end

end
