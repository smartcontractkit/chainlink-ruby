# Nayru

A ruby implementation of an oracle for interfacing with Smart Contracts. Nayru supports creating adapters to interface with a variety of blockchains and traditional services.

By default Nayru ships with support for Ethereum and Bitcoin. Additional resources, such as other blockchains and off-chain services, can be plugged into Nayru by creating a schema for the data they require. Once the schema is specified, Nayru's protocol makes it easy to make these services interact with each other. By standardizing the way the interface for these services, on-chain to off-chain computation and cross-chain interactions become much easier.

## Protocol

### Adapters
The adapter protocol allows for anyone running a Nayru instance to specify what they need to work with a service. Adapters can have as much or as little logic as is needed. There are two parts to any adapter, input and output.

### Input
There are two ways to trigger input adapters: on-chain requests, and off-chain requests. Adapters currently support one type or the other. The need for both on-chain and off-chain input can be solved by chaining adapters together. All adapters can also provide preset information.

#### On-Chain Input
Adapters can specify on-chain interfaces to allow for requests to be made on-chain. This can be useful for pulling off-chain information on-chain, or pushing information off-chain via on-chain logic.

Example 1: An Ethereum oracle can provide an interface to retrieve the current stock price of the stock ticker symbol provided in the request.

Example 2: A Bitcoin oracle can watch a certain address for an OP_RETURN message specifying a stock ticker symbol, and release a UTXO based on a preset price comparison.

#### Off-Chain Input
Adapters can specify off-chain interfaces, so that traditional resources like HTTP requests can affect on-chain resources.

Example 1: Push notifications can be translated to signed transactions on the blockchain.

Example 2: Configuration, like credentials, for an adapter can be reset as needed.


#### Preset Input
Preset information is set in the initial assignment for the oracle. Presets can affect later input and output requests, like with credentials, but is specified in the inputs section.

Example 1: When interacting with a stock price adapter, you may always want the closing price of Apple stock. The preset information in this case would be the Apple stock ticker symbol, AAPL. By specifying this up front, a request does not need to be made everytime you need a price.

Example 2: When interacting with a private data feed, you may need to specify credentials. By passing these credentials in the assignment ahead of time, they are never exposed on chain.

### Output
The actions triggered by adapters is specified in the output section of an adapter. Output can take two forms: on-chain AND/OR off-chain.

#### On-Chain Output
Adapters can specify the effects that outcomes can have on blockchains, and the interfaces that the outcomes will be visible through.

Example 1: An Ethereum oracle is updated daily, and the address and method for data retrieval are specified.

Example 2: A Bitcoin payment is recorded on the Bitcoin blockchain following an update triggered on the Ethereum blockchain.

#### Off-Chain Ouput
Adapters can specify the effects that outcomes can have off of a blockchain, and the interfaces that the outcomes will be visible through.

Example 1: An HTTP notification is sent to a website after a payment is made.

Example 2: Payment via a traditional banking site is released via authentication with the bank and credentials stored with the adapter.



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
