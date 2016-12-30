class JsonAdapter < ActiveRecord::Base
  SCHEMA_NAME = 'httpGetJSON'

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


  private

  def set_up_from_body
    return unless body.present?

    self.url = body['url'] || body['endpoint']
    self.fields = body['fields']
    self.request_type = body['requestType'] || 'GET'
  end

end
