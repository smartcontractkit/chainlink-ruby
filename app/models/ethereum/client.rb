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

  def account_balance(account)
    hex_to_int epost('eth_getBalance', [to_eth_hex(account), 'latest']).result
  end

  def client_version
    epost 'web3_clientVersion'
  end

  def gas_price
    hex_to_int epost('eth_gasPrice').result
  end

  def current_block_height(options = {})
    hex_to_int epost('eth_blockNumber').result
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
      gas: to_eth_hex(options[:gas] || 1_000_000_000),
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

  def get_transaction_count(account)
    hex_to_int epost('eth_getTransactionCount', [account, 'pending']).result
  end

  def utf8_to_hex(string)
    string.force_encoding('ASCII').bytes.map{|byte| byte.to_s(16) }.join
  end

  def hex_to_utf8(hex)
    hex_to_bytes32(hex).delete(Ethereum::EMPTY_BYTE)
  end

  def hex_to_bytes32(hex)
    hex.gsub(/\A0x/,'').scan(/.{2}/).map{|byte| byte.hex}.pack("C*").force_encoding('utf-8')
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

  def hex_to_int(hex)
    hex.gsub(/\A0x/,'').to_i(16) if hex.present?
  end

  def solidity
    @solidity ||= SolidityClient.new
  end

  def to_eth_hex(data)
    self.class.hex data
  end

  def format_address_hex(address)
    address.to_s.gsub(/^0x/,'').rjust(64, "0")
  end

  def format_hex_array(array_of_hex)
    format_int_to_hex(array_of_hex.size) + array_of_hex.join
  end

  def format_int_to_hex(integer, bytes = 32)
    integer.to_s(16).rjust(2 * bytes, '0')
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

end
