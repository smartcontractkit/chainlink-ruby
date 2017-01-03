class EthereumOracle < ActiveRecord::Base
  SCHEMA_NAME = 'ethereumBytes32JSON'

  has_one :adapter_assignment, as: :adapter
  has_one :assignment, as: :adapter
  has_one :ethereum_contract, as: :owner
  has_one :term, as: :expectation
  has_many :writes, class_name: 'EthereumOracleWrite', as: :oracle

  validates :endpoint, format: { with: /\A#{CustomExpectation::URL_REGEXP}\z/x }
  validates :ethereum_contract, presence: true
  validates :fields, presence: true

  before_validation :set_up_from_body, on: :create

  attr_accessor :body


  def fields=(fields)
    self.field_list = Array.wrap(fields).to_json if fields.present?
    self.fields
  end

  def fields
    return [] if field_list.blank?
    JSON.parse(field_list)
  end

  def current_value
    return @current_value if @current_value.present?
    endpoint_response = HttpRetriever.get(endpoint)
    @current_value = JsonTraverser.parse endpoint_response, fields
  end

  def start(assignment)
    # see Assignment#start_tracking
    Hashie::Mash.new errors: tap(&:valid?).errors.full_messages
  end

  def stop(assignment)
    # see Assignment#close_out!
  end

  def close_out!
    # see Term#update_status
  end

  def assignment_type
    'ethereum'
  end

  def related_term
    term || assignment.term
  end

  def get_status(assignment_snapshot, _details = {})
    write = updater.perform
    assignment_snapshot.xid = write.txid if write.success?
    write.snapshot_decorator
  end

  def check_status
    assignment.check_status
  end

  def schema_errors_for(parameters)
    []
  end

  def type_name
    SCHEMA_NAME
  end

  def coordinator
    assignment.coordinator
  end


  private

  def set_up_from_body
    return unless body.present?

    self.endpoint = body['endpoint']
    self.fields = body['fields']
    build_ethereum_contract
  end

  def updater
    Ethereum::OracleUpdater.new(self)
  end

end
