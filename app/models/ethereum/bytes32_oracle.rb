require 'ethereum'

module Ethereum
  class Bytes32Oracle < ActiveRecord::Base
    SCHEMA_NAME = 'ethereumBytes32'

    include AdapterBase

    belongs_to :ethereum_account, class_name: 'Ethereum::Account'
    has_one :subtask, as: :adapter
    has_one :assignment, through: :subtask
    has_one :ethereum_contract, as: :owner
    has_many :writes, class_name: 'EthereumOracleWrite', as: :oracle

    validates :address, format: { with: /\A0x[0-9a-f]{40}\z/, allow_nil: true }
    validates :update_address, format: { with: /\A(?:0x)?[0-9a-f]*\z/, allow_nil: true }

    before_validation :set_up_from_body, on: :create
    after_create :delay_initial_status_check


    def get_status(assignment_snapshot, params = {})
      current_value = params && params.with_indifferent_access['value']
      write = updater.perform(current_value)
      write.snapshot_decorator
    end

    def account
      ethereum_account || ethereum_contract.try(:account)
    end

    def contract_address
      address || ethereum_contract.address
    end

    def contract_write_address
      update_address || ethereum_contract.write_address
    end


    private

    def set_up_from_body
      if body.present?
        self.address = body['address']
        self.update_address = body['updateAddress'] || body['method']
      end

      if address.nil?
        build_ethereum_contract
      else
        self.ethereum_account = Account.default
      end
    end

    def updater
      Ethereum::OracleUpdater.new(self)
    end

    def delay_initial_status_check
      self.delay.check_initial_status
    end

    def check_initial_status
      reload.check_status if assignment.present? && ethereum_contract.blank?
    end

  end
end
