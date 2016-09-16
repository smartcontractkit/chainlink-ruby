class SchemaValidator
  UUID_REGEX = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

  attr_reader :errors, :schema

  def initialize(schema)
    @schema = schema.is_a?(String) ? JSON.parse(schema) : schema
    @errors = []
  end

  def validate(hash)
    process_errors JSON::Validator.fully_validate(schema, hash)
    errors.empty?
  end


  private

  def process_errors(errors)
    @errors = errors.map do |error|
      error.gsub(/ in schema #{UUID_REGEX}#?/, '')
    end
  end

end
