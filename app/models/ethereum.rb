module Ethereum
  WEI_PER_ETHER ||= 10**18
  NULL_ACCOUNT ||= "0x#{'0' * 40}"
  EMPTY_BYTE ||= "\x00".encode('utf-8', 'utf-8', invalid: :replace)

  def self.table_name_prefix
    'ethereum_'
  end

end
