# Nayru

A ruby implementation of a node running the [Smart Oracles Protocol](https://github.com/pivotal/vim-config/commits/master) for interfacing with smart contracts. Nayru supports creating adapters to interface with a variety of blockchains and traditional services.

## Setup

### Configuration

The configuration settings for Nayru are stored in the `.env` file. See `.env.example` for the list of required fields.

### Database

Nayru by default saves most of its information in Postgres. You need an instance of Postgres running, v9.3 or above. This can run on the same machine as the node, but should be kept separate from any containers used to run an instance of Nayru.

## Development

### Install

```
bundle
rake db:create db:migrate
```

### Testing
```
npm install -g ethereumjs-testrpc
testrpc --account="0x721b3cb22661758e0a4b9d587cbe5ce672257cde7567bc7cd6640279e686391a,10000000000000000000000000" # or whatever private key you prefer
rake
```
