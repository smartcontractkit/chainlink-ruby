require 'ethereum'

module Ethereum
  class Bytes32Oracle < ActiveRecord::Base
    SCHEMA_NAME = 'ethereumBytes32'

    attr_accessor :body

  end
end
