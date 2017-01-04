require 'ethereum'

module Ethereum
  class Bytes32Oracle < ActiveRecord::Base
    SCHEMA_NAME = 'ethereumBytes32'

    belongs_to :ethereum_account, class_name: 'Ethereum::Account'
    has_one :assignment, as: :adapter
    has_one :ethereum_contract, as: :owner

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
  end
end
