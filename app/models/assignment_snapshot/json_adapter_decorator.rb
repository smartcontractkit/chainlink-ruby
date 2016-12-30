class AssignmentSnapshot
  class JsonAdapterDecorator < Decorator

    attr_reader :record, :value

    def initialize(record, value, errors)
      @record = record
      @value = value
      @errors = errors
    end

    def summary
      return if assignment.blank?
      if value.present?
        "The parsed JSON returned \"#{value}\"."
      else
        "#{assignment.name} parsed a null value."
      end
    end

    def details
      {value: value}
    end


    private

    def assignment
      record.assignment
    end

  end
end
