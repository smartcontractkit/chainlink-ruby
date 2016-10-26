class SolidityClient

  include HttpClient
  base_uri (ENV['SOLIDITY_URL'] || 'https://solc.smartcontract.com/api')

  def compile(code)
    json_post('/compile', solidity: code)
  end

end
