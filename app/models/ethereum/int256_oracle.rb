require 'ethereum'

module Ethereum
  class Int256Oracle < OracleBase

    SCHEMA_NAME = 'ethereumInt256'

    def get_status(assignment_snapshot, previous_snapshot = nil)
      base_value = previous_snapshot.try(:value)
      value = (base_value.to_f * result_multiplier).round
      write = updater.perform format_hex_value(value), value
      write.snapshot_decorator
    end


    private

    def set_up_for_format_from_body
      if body.present?
        self.result_multiplier = body['resultMultiplier'].to_i if body['resultMultiplier'].present?
      end
      self.result_multiplier ||= 1
    end

    def format_hex_value(value)
      Ethereum::Client.new.format_int_to_hex value
    end

  end
end
