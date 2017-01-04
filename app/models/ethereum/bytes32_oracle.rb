require 'ethereum'

module Ethereum
  class Bytes32Oracle < ActiveRecord::Base
    SCHEMA_NAME = 'ethereumBytes32'

    belongs_to :ethereum_account, class_name: 'Ethereum::Account'
    has_one :adapter_assignment, as: :adapter
    has_one :assignment, through: :adapter_assignment
    has_one :ethereum_contract, as: :owner
    has_many :writes, class_name: 'EthereumOracleWrite', as: :oracle

    validates :address, format: { with: /\A0x[0-9a-f]{40}\z/, allow_nil: true }
    validates :update_address, format: { with: /\A(?:0x)?[0-9a-f]*\z/, allow_nil: true }

    before_validation :set_up_from_body, on: :create

    attr_accessor :body

    def coordinator
      assignment.coordinator
    end

    def check_status
      assignment.check_status
    end

    def start(assignment)
      # see Assignment#start_tracking
      Hashie::Mash.new errors: tap(&:valid?).errors.full_messages
    end

    def stop(assignment)
      # see Assignment#close_out!
    end

    def close_out!
      # see Term#update_status
    end

    def get_status(assignment_snapshot, params = {})
      current_value = params && params.with_indifferent_access['value']
      write = updater.perform(current_value)
      write.snapshot_decorator
    end

    def account
      ethereum_account || ethereum_contract.try(:account)
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

  end
end
