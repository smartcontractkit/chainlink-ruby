class Ethereum::Client

  include HttpClient
  base_uri ENV['ETHEREUM_URL']


  def self.tx_url(txid)
    "#{ENV['ETHEREUM_EXPLORER_URL']}/tx/#{txid}"
  end

  def self.hex(data)
    return data if data.blank?
    data = data.to_s(16) if data.is_a? Integer
    (data[0..1] == '0x') ? data : "0x#{data}"
  end

  def account_balance(account, tag = 'latest')
    hex_to_uint epost('eth_getBalance', [to_eth_hex(account), tag]).result
  end

  def client_version
    epost 'web3_clientVersion'
  end

  def gas_price
    current = hex_to_uint(epost('eth_gasPrice').result)
    minimum = ENV['ETHEREUM_GAS_PRICE_MINIMUM'].to_i
    [current, minimum].max
  end

  def current_block_height(options = {})
    hex_to_uint epost('eth_blockNumber').result
  end

  def create_transaction(options)
    epost('eth_sendTransaction', {
      data: to_eth_hex(options[:data]),
      from: eth_account(options[:from] || Ethereum::Account.default),
      gas: to_eth_hex(options[:gas]),
      gasPrice: hex_gas_price(options[:gas_price]),
      to: eth_account(options[:to]),
      value: to_eth_hex(options[:value]),
    }).tap { |response| response.txid = response.result }
  end

  def send_raw_transaction(hex)
    epost('eth_sendRawTransaction', to_eth_hex(hex)).tap do |response|
      response.txid = response.result
    end
  end

  def call(options)
    epost('eth_call', [{
      data: to_eth_hex(options[:data]),
      from: eth_account(options[:from] || Ethereum::NULL_ACCOUNT),
      gas: to_eth_hex(options[:gas] || 1_000_000),
      gasPrice: hex_gas_price(options[:gas_price]),
      to: eth_account(options[:to]),
      value: to_eth_hex(options[:value] || 0),
    }, 'latest'])
  end

  def get_transaction(txid)
    epost('eth_getTransactionByHash', txid).result
  end

  def get_transaction_receipt(txid)
    epost('eth_getTransactionReceipt', txid).result
  end

  def get_transaction_count(account, tag = 'pending')
    hex_to_uint epost('eth_getTransactionCount', [account, tag]).result
  end

  def get_block(hash, full = false)
    epost('eth_getBlockByHash', [hash, full])
  end

  def utf8_to_hex(string)
    string.force_encoding('ASCII').bytes.map{|byte| byte.to_s(16) }.join
  end

  def hex_to_utf8(hex)
    hex_to_bytes32(hex).delete(Ethereum::EMPTY_BYTE)
  end

  def hex_to_bytes32(hex)
    sub_hex_prefix(hex).scan(/.{2}/).map{|byte| byte.hex}.pack("C*").force_encoding('utf-8')
  end

  def format_string_hex(input, base_offset = 32)
    string = input.dup.to_s.force_encoding 'ASCII'
    byte_size = string.bytes.size

    content_offset = base_offset.to_s(16).rjust(64, '0')
    size_32bytes = byte_size.to_s(16).rjust(64, '0')
    slots_required = (byte_size / 32) + 1
    padded_hex = utf8_to_hex(string).ljust(slots_required * 64, '0')

    content_offset + size_32bytes + padded_hex
  end

  def format_bytes32_hex(input)
    string = input.dup.to_s.force_encoding 'ASCII'
    utf8_to_hex(string[0...32]).ljust(64, '0')
  end

  def hex_to_uint(hex)
    return if hex.blank?
    sub_hex_prefix(hex).to_i(16)
  end

  def hex_to_address(hex)
    return if hex.blank?
    "0x#{sub_hex_prefix(hex)[-40..-1]}"
  end

  def hex_to_boolean(hex)
    return if hex.blank?
    hex_to_uint(hex) == 1
  end

  def hex_to_int(hex, size = 256)
    return if hex.blank?
    value = sub_hex_prefix(hex).to_i(16)
    value >= 2**(size-1) ? (value - 2**size) : value
  end

  def solidity
    @solidity ||= SolidityClient.new
  end

  def to_eth_hex(data)
    self.class.hex data
  end

  def format_address_hex(address)
    sub_hex_prefix(address).rjust(64, "0")
  end

  def format_hex_array(array_of_hex)
    format_uint_to_hex(array_of_hex.size) + array_of_hex.join
  end

  def format_uint_to_hex(integer, bits = 256)
    integer.abs.to_s(16).rjust(2 * bits_to_bytes(bits), '0')
  end

  def format_int_to_hex(integer, bits = 256)
    value = integer < 0 ? (integer + 2**bits) : integer
    format_uint_to_hex(value, bits)
  end

  def get_code(address, tag = 'pending')
    epost('eth_getCode', [address, tag]).result
  end

  def get_filter_logs(filter_id)
    response = epost('eth_getFilterLogs', filter_id)
    raise response.error.to_json if response.error.present?
    Array.wrap(response.result).compact
  end

  def get_filter_changes(filter_id)
    response = epost('eth_getFilterChanges', filter_id)
    raise response.error.to_json if response.error.present?
    Array.wrap(response.result).compact
  end

  def uninstall_filter(filter_id)
    Array.wrap(epost('eth_uninstall', filter_id).result).flatten
  end

  def get_logs(options)
    epost('eth_getLogs', options)
  end


  private

  def epost(method_name, params = nil)
    hashie_post('/', {
      id: HttpClient.random_id,
      jsonrpc: "2.0",
      method: method_name,
      params: Array.wrap(params).compact,
    }.to_json)
  end

  def http_client_auth_params
    if ENV['ETHEREUM_PASSWORD'].present? && ENV['ETHEREUM_USERNAME'].present?
      {
        password: ENV['ETHEREUM_PASSWORD'],
        username: ENV['ETHEREUM_USERNAME'],
      }
    else
      nil
    end
  end

  def headers
    { "Content-Type" => "application/json" }
  end

  def eth_account(account)
    return if account.blank?
    account.instance_of?(Ethereum::Account) ? account.address : account
  end

  def hex_gas_price(price)
    to_eth_hex(price || gas_price)
  end

  def sub_hex_prefix(hex)
    hex.to_s.gsub(/\A0x/,'')
  end

  def bits_to_bytes(bits)
    raise "Not a number of bits that can fit with bytes" unless bits % 8 == 0
    bits / 8
  end

end
