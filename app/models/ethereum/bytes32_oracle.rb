require 'ethereum'

module Ethereum
  class Bytes32Oracle < OracleBase

    SCHEMA_NAME = 'ethereumBytes32'

    def get_status(assignment_snapshot, previous_snapshot = nil)
      value = previous_snapshot.try(:value).to_s[0..31]
      write = updater.perform format_hex_value(value), value
      write.snapshot_decorator
    end


    private

    def format_hex_value(value)
      Ethereum::Client.new.format_bytes32_hex value
    end

  end
end
