class JsonAdapter < ActiveRecord::Base
  SCHEMA_NAME = 'httpGetJSON'

  has_one :adapter_assignment, as: :adapter
  has_one :assignment, through: :adapter_assignment

  validates :fields, presence: true
  validates :request_type, inclusion: { in: ['GET'] }
  validates :url, format: { with: /\A#{CustomExpectation::URL_REGEXP}\z/x }

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

  def coordinator
    assignment.coordinator
  end

  def check_status
    assignment.check_status
  end

  def get_status(_assignment, _params)
    AssignmentSnapshot::JsonAdapterDecorator.new(self, current_value, [])
  end


  private

  def set_up_from_body
    return unless body.present?

    self.url = body['url'] || body['endpoint']
    self.fields = body['fields']
    self.request_type = body['requestType'] || 'GET'
  end

  def current_value
    return @current_value if @current_value.present?
    response = HttpRetriever.get(url)
    @current_value = JsonTraverser.parse response, fields
  end

end
