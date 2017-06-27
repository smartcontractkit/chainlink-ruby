# Smart Oracle [![Code Climate](https://codeclimate.com/github/oraclekit/smart_oracle/badges/gpa.svg)](https://codeclimate.com/github/oraclekit/smart_oracle)

## API

See the [API documentation](https://smartoracle.smartcontract.com) for more details about the API.

## Overview

### Assignments

Assignments are the main model for defining work to be done by a Smart Oracle. An Assignment specifies a series of processing steps, Subtasks, which form a processing pipeline. Assignments include up front configuration for the Subtask pipeline, as well as instructions on when and how the Assignment can be triggered to run.

### Snapshots

Whenever an Assignment is triggered to run, a Snapshot is created. The Snapshot is the record of the work that was done, and the steps taken along the way to reach the final Snapshot result.

Snapshots can be triggered either through upfront scheduling of the Assignment and/or by on demand requests through any of the Adapters.

### Subtasks

Assignments are made up of a sequence of Subtasks. Subtasks are small specialized processes, designed to be modular and reusable with many other types of Subtasks.

Every time a Snapshot is created it starts by processing the first Subtask. The result of each Subtask is fed into the next Subtask, until the final Subtask is processed. The result of the final Subtask becomes the result of the entire Snapshot.

Data is passed between Subtasks as a JSON payload. By convention the main field that information is read from is stored as the top level key `value`, but other keys can be used and additional information can be stored in their payload.

Subtasks are initially configured when an assignment is defined, but they can also be dynamically configured with the data passed in from previous Subtasks.

### Adapters

The processing work for each Subtask is handled by its Adapter. Adapters are where the processing and communication with external services happens. Subtasks are specific configurations of how work is to be handled by an Adapter.

The Smart Oracle core ships with a few adapters built in, but additional External Adapters can be created to add custom functionality. External Adapters are external services, which are communicated with via HTTP. External Adapters allow for functionality of the Smart Oracle to be easily extended and can be written in which ever language is best suited. Conforming to a [minimal HTTP interface](https://smartoracle.smartcontract.com/#adapter-integration) is the only requirement for creating your custom External Adapters.

The Adapters that ship with the Smart Oracle core are:

- [__bitcoinComparisonJSON__](https://chainlink-docs.smartcontract.com/#bitcoincomparisonjson) Returns a signed Bitcoin transaction. Signs either a completion transaction or a failure transaction based on a value comparison of the input.
- [__ethereumBytes32__](https://chainlink-docs.smartcontract.com/#ethereumbytes32) Formats the input as Ethereum `bytes32` value and writes it into the specified contract. Returns the unformatted value that was provided as input.
- [__ethereumInt256__](https://chainlink-docs.smartcontract.com/#ethereumint256) Formats the input as Ethereum `int256` value and writes it into the specified contract. Returns the unformatted value that was provided as input.
- [__ethereumUint256__](https://chainlink-docs.smartcontract.com/#ethereumuint256) Formats the input as Ethereum `uint256` value and writes it into the specified contract. Returns the unformatted value that was provided as input.
- [__ethereumFormatted__](https://chainlink-docs.smartcontract.com/#ethereumformatted) Writes a preformatted Ethereum hexadecimal value into the blockchain as configured. Returns the preformatted value that was provided as input.
- [__ethereumLogWatcher__](https://chainlink-docs.smartcontract.com/#ethereumlogwatcher) Returns the `data` field of an Ethereum event log, if one is provided. Otherwise, returns the value that was provided as the input. (Requires [WeiWatchers](https://github.com/oraclekit/wei_watchers) integration.)
- [__httpGetJSON__](https://chainlink-docs.smartcontract.com/#httpgetjson) Retrieves JSON and returns the specific field selected in the configuration.
- [__jsonReceiver__](https://chainlink-docs.smartcontract.com/#jsonreceiver) Generates a URL for the oracle to receive JSON push notifications. Parses the pushed JSON and returns the specific field selected in the configuration.

If you are interested in other types of Adapters feel free to [reach out](mailto:support@smartcontract.com).

### Adapter Schemas

Adapter Schemas allow for Adapters to be modular enough to be used with many types of Adapters, but still remain reliable when used with other Adapters that may not even be defined yet. Adapter Schemas are [JSON Schemas](http://json-schema.org/) that specify the input requirements and output formats of each adapter. For more information on the various schemas used by the Smart Oracle check out the [Schemas repo](https://github.com/oraclekit/schemas).



## Development

### Requirements

- ruby(v2.0.0+)
- postgres(v9.3+)

### Install

```
git clone https://github.com/oraclekit/smart_oracle && cd smart_oracle
gem install bundler && bundle
rake db:create db:migrate
```

### Start
```
foreman start
```

## Testing

To run the full test suite, including integration tests, you need an instance of DevNet running on your machine. This requires first installing [Parity](https://github.com/paritytech/parity). Once Parity is installed, run the following commands:

```
git clone https://github.com/oraclekit/devnet.git
cd devnet
./start
```

Then to run the full test suite run:
```
rake
```

Or test a specific test:
```
rspec spec/models/assignment_spec.rb:57
```
