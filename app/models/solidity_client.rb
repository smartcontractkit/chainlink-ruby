class SolidityClient

  include HttpClient
  base_uri (ENV['SOLIDITY_URL'] || 'https://solc.smartcontract.com/api')

  def self.compile(code)
    new.compile code
  end

  def self.sol_abi(name, json_abi)
    new.sol_abi name, json_abi
  end

  def compile(code)
    json_post '/compile', solidity: code
  end

  def sol_abi(name, json_abi)
    functions = JSON.parse(json_abi).map do |function|
      sol_signature name, function
    end.sort.join

    "contract #{name} {\n#{functions}}"
  end


  private

  def sol_signature(contract_name, json_abi)
    type = ['function', 'constructor'].include?(json_abi['type']) ? 'function' : 'event'
    name = json_abi['name'] || (json_abi['type'] == 'constructor' ? contract_name : nil)
    inputs = json_abi['inputs'].map do |input|
      "#{input['type']}#{(' ' + input['name']) if input['name'].present?}"
    end.join(', ')
    constant = json_abi['constant'] ? ' constant' : ''
    outputs = json_abi['outputs']
    if outputs.present?
      return_values = outputs.map do |output|
        "#{output['type']}#{(' ' + output['name']) if output['name'].present?}"
      end
      returns = " returns (#{return_values.join(', ')})"
    else
      returns = ''
    end

    "\t#{type} #{name}(#{inputs})#{constant}#{returns};\n"
  end
end
