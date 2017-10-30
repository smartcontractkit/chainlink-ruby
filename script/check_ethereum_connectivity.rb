require 'ethereum'
ethereum = Ethereum::Client.new
puts "Connecting to Ethereum node on #{Ethereum::Client.base_uri}: current block height #{ethereum.current_block_height}"
