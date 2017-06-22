# Smart Oracle Core

## API

See the [API documentation](https://smartoracle.smartcontract.com) for more details about the API.

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
To run the full test suite [geth](https://github.com/ethereum/go-ethereum) must be installed. For the duration of the test run, geth will spin up and listen on port 7434.

To run the full test suite run:
```
rake
```

## TODO
- improve documentation
- improve support for future types of output
- integrate HD key support for coordinators
- support on demand requests from Ethereum contracts by default
- extract EVM for first version of computation within adapters
