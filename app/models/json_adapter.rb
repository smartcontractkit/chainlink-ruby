class JsonAdapter < ActiveRecord::Base
  SCHEMA_NAME = 'httpGetJSON'

  include AdapterBase

  has_one :subtask, as: :adapter
  has_one :assignment, through: :subtask

  validates :fields, presence: true
  validates :request_type, inclusion: { in: ['GET'] }
  validates :url, format: { with: /\A#{CustomExpectation::URL_REGEXP}\z/x }

  before_validation :set_up_from_body, on: :create


  def fields=(fields)
    self.field_list = Array.wrap(fields).to_json if fields.present?
    self.fields
  end

  def headers=(headers)
    self.headers_json = headers ? headers.to_json : headers
    self.headers
  end

  def headers
    JSON.parse(headers_json) if headers_json.present?
  end

  def fields
    return [] if field_list.blank?
    JSON.parse(field_list)
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
    self.headers = body['headers']
    if basic_auth = body['basicAuth']
      self.basic_auth_password = basic_auth['password']
      self.basic_auth_username = basic_auth['username']
    end
  end

  def current_value
    return @current_value if @current_value.present?
    response = HttpRetriever.get url, options
    @current_value = JsonTraverser.parse response, fields
  end

  def basic_auth
    if basic_auth_username.present? || basic_auth_password.present?
      {
        username: basic_auth_username,
        password: basic_auth_password,
      }.compact
    end
  end

  def options
    {
      basic_auth: basic_auth,
      headers: headers,
    }.compact
  end

end
