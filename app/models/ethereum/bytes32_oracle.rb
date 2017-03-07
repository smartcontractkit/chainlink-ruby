require 'ethereum'

module Ethereum
  class Bytes32Oracle < ActiveRecord::Base
    SCHEMA_NAME = 'ethereumBytes32'

    include AdapterBase

    belongs_to :ethereum_account, class_name: 'Ethereum::Account'
    has_one :subtask, as: :adapter
    has_one :assignment, through: :subtask
    has_one :ethereum_contract, as: :owner
    has_one :template, through: :ethereum_contract
    has_many :writes, class_name: 'EthereumOracleWrite', as: :oracle

    validates :address, format: { with: /\A0x[0-9a-f]{40}\z/i, allow_nil: true }
    validates :update_address, format: { with: /\A(?:0x)?[0-9a-f]*\z/, allow_nil: true }

    before_validation :set_up_from_body, on: :create


    def get_status(assignment_snapshot, previous_snapshot = nil)
      value = previous_snapshot.try(:value).to_s[0..31]
      write = updater.perform format_hex_value(value), value
      write.snapshot_decorator
    end

    def account
      ethereum_account || ethereum_contract.try(:account)
    end

    def contract_address
      address || ethereum_contract.try(:address)
    end

    def contract_write_address
      update_address || ethereum_contract.write_address
    end

    def ready?
      contract_address.present?
    end

    def contract_confirmed(address)
      subtask.mark_ready if address.present?
    end

    def initialization_details
      if ethereum_contract.present?
        full_contract_details
      else
        external_contract_details
      end
    end


    private

    def set_up_from_body
      if body.present?
        self.address = body['address']
        self.update_address = body['updateAddress'] || body['method']
      end

      if address.nil?
        build_ethereum_contract adapter_type: SCHEMA_NAME
      else
        self.ethereum_account = Account.default
      end
    end

    def updater
      Ethereum::OracleUpdater.new(self)
    end

    def full_contract_details
      external_contract_details.merge({
        jsonABI: template.json_abi,
        readAddress: template.read_address,
        solidityABI: template.solidity_abi,
      })
    end

    def external_contract_details
      {
        address: contract_address,
        writeAddress: contract_write_address
      }
    end

    def format_hex_value(value)
      Ethereum::Client.new.format_bytes32_hex value
    end

  end
end
