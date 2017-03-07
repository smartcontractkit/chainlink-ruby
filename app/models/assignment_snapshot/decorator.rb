class AssignmentSnapshot
  class Decorator

    def initialize(record)
      @record = record
    end

    def status
      nil
    end

    def fulfilled
      true
    end

    def description
      nil
    end

    def description_url
      nil
    end

    def details
      nil
    end

    def value
      raise "#value not implemented in #{self.class.name}"
    end

    def errors
      record.errors
    end

    def present?
      record.present?
    end

    def config
      record.subtask.parameters
    end


    private

    attr_reader :record

  end
end
