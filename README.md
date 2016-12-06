# Smart Oracle Core

## API

See the [API documentation](https://smartoracles.github.io/api-docs) for more details about the API.

## Development

### Requirements

- ruby(v2.0.0+)
- postgres(v9.3+)

### Install Core

```
git clone https://github.com/smartoracles/core-ruby smartoracles-core && cd smartoracles-core
gem install bundler
bundle
rake db:create db:migrate
```

### Start
```
foreman start
```

### Testing
```
npm install -g ethereumjs-testrpc
testrpc --account="0x721b3cb22661758e0a4b9d587cbe5ce672257cde7567bc7cd6640279e686391a,10000000000000000000000000" # or whatever private key you prefer
rake
```

## TODO
- improve documentation
- improve support for future types of output
- integrate HD key support for coordinators
- support on demand requests from Ethereum contracts by default
- extract EVM for first version of computation within adapters
