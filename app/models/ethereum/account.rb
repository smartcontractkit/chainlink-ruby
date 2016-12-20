require 'ethereum'

module Ethereum
  class Account < ActiveRecord::Base

    include HasEthereumClient

    has_one :key_pair, as: :owner
    has_many :ethereum_transactions, foreign_key: :account_id

    validates :address, format: /\A0x[0-9a-f]{40}\z/, uniqueness: true

    before_validation :generate_key_pair, on: :create, unless: :address

    scope :local, -> { joins(:key_pair).where.not('key_pairs.id' => nil) }

    def self.default
      find_by(address: ENV['ETHEREUM_ACCOUNT']) ||
        local.order(:created_at).first
    end

    def sign(tx)
      return if key_pair.blank?
      tx.sign key_pair.ethereum_key
    end

    def next_nonce
      if database_nonce = ethereum_transactions.maximum(:nonce)
        database_nonce + 1
      else
        ethereum.get_transaction_count address
      end
    end

    def send_transaction(params)
      tx_builder.perform(params).tap do |tx|
        ethereum.send_raw_transaction tx.raw_hex
      end
    end

    def sign_hash(hash)
      key_pair.ethereum_key.sign_hash hash
    end

    def public_key
      key_pair.uncompressed_public_key
    end


    private

    def tx_builder
      Ethereum::TransactionBuilder.new self
    end

    def generate_key_pair
      self.key_pair = KeyPair.create
      self.address = key_pair.ethereum_address
    end

  end
end
