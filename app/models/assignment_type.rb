class AssignmentType < ActiveRecord::Base

  has_one :input_adapter

  validates :json_schema, presence: true
  validates :name, presence: true, uniqueness: true
  validate :parsable_schema

  def scheduled?
    !unscheduled?
  end

  def schema_errors_for(parameters)
    return [] if schema_validator.blank?
    schema_validator.validate parameters
    schema_validator.errors
  end


  private

  def schema_validator
    if preset_schema.present?
      @schema_validator ||= SchemaValidator.new(preset_schema)
    end
  end

  def preset_schema
    input_schema.preset if input_schema.present?
  end

  def input_schema
    Hashie::Mash.new(JSON.parse json_schema).input
  end

  def parsable_schema
    begin
      JSON.parse(json_schema)
    rescue
      errors.add :json_schema, "is not valid JSON"
    end
  end

end
