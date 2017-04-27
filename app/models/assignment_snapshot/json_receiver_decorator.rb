class AssignmentSnapshot
  class JsonReceiverDecorator < Decorator

    def summary
      "Snapshot triggered."
    end

    def description
      nil
    end

    def description_url
      nil
    end

    def value
      record.value
    end

    def details
      record.data
    end

    def errors
      []
    end

    def config
      record.subtask.parameters
    end

  end
end
