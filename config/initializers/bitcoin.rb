if Rails.env.test? #|| Rails.env.development?
  Bitcoin.network = :testnet3
else
  Bitcoin.network = (ENV['BITCOIN_NETWORK'] || :bitcoin).to_sym
end
