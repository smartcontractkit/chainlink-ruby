# Smart Oracle Core

A ruby implementation of a core node running the [Smart Oracles Protocol](https://github.com/pivotal/vim-config/commits/master). The core provides a simple API for creating adapters to deal with various blockchains and off-chain services.

## Setup

### Configuration

The configuration settings for Nayru are stored in the `.env` file. See `.env.example` for the list of required fields.

### Database

Most of information, by default, is stored in Postgres. You'll need an instance of Postgres v9.3 or above. This can run on the same machine as the node, but if run in a container, it should be kept outside the container.

## Development

### Install

```
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
- improve support for future types of output
- integrate HD key support for coordinators
- support on demand requests from Ethereum contracts by default
- extract EVM for first version of computation within adapters
