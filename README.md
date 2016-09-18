# Smart Oracle Core

A ruby implementation of a core node running the [Smart Oracles Protocol](https://github.com/pivotal/vim-config/commits/master). The core provides a simple API for creating adapters to deal with various blockchains and off-chain services. Logic including key management, scheduling, and connectivity is consolidated in the core, so the adapter logic can be kept be focused on elsewhere. If you require finer grained control than what is provided, this logic can be controlled at the adapter level.

## Usage

The ruby implementation of core ships with two adapters:
- a JSON retriever for Ethereum
- a JSON retriever and value comparison for Bitcoin escrow release

The easiest way to get started is to spin up an instance in docker. Once you have an instance of the oracle running, you can `POST` new assignments to `/assignments`. Assignments of each type must conform to their [corresponding schemas](https://github.com/smartoracles/core-ruby/tree/develop/lib/assets/schemas).

## Adapters

Building a custom adapter to for the core is simple.

There are a minimum of three restful API calls to create, but more can be added for greater control and clarity. All API calls must be authenticated, and a 200 response code is treated as a successful response.

For interoperation between adapters, and predicability about input and output, defining a schema for your adapter is highly encouraged. Schemas offer the benefit of predicatability between consumer and oracle providers, and additionally make it possible to chain adapters.

### API Calls

#### Required API Calls

##### Create Assignment

Used to create a new piece of work for an adapter.

`POST` to `/assignments` including keys `xid`, `end_at`, and `data`.

Response fields:
  - `xid`: String. The ID provided in the request to create the assignment.

##### Create Snapshot (Pull)

Used to retrieve the current status of a piece of work.

`POST` to `/assignments/{xid}/snapshots` which additionally includes the assignment's `xid` in the body.

Response fields:
  - `details`: JSON object. data which corresponds to the output schema specified by the adapter.
  - `description`: String(optional). Additional human readable clarifying information, secondary to `summary`.
  - `description_url`: String(optional). Additional clarifying link, secondary to `summary`.
  - `fulfilled`: Boolean. Should always be true, unless the Update Snapshot push notification is enabled. If it is false, no additional information needs to be provided in the response, but the adapter commits to responding once the work required to get a snapshot is completed, at which point it pushes an updated to the snapshot.
  - `status`: String(optional). The current status of the assignment. If changed to completed or failed, this will end the assignment before the originally specified deadline.
  - `summary`: String. A human readable summary of the assignment's current status.
  - `value`: String. The current value that the assignment has reached. If more information is needed, it should be provided in the `details` field.
  - `xid`: String. A new ID to identify the snapshot by.

##### Delete Assignment

Used to indicate the end of an assignment.

`DELETE` to `/assignments/{xid}/snapshots` which additionally includes the assignment's `xid` in the body.

Response fields:
  - `status`: String(optional). The final status of the assignment.
  - `xid`: String. A new ID to identify the snapshot by.

#### Optional API calls

##### Create Snapshot (Push)

Used for updates that are pushed, or scheduled outside of the core.

`POST` from the adapter to the core at the `/snapshots` route. The request body must include `xid`, `details`, `summary`, and `value`.

##### Update Snapshot (Push)

Used to update unfulfilled snapshots(see "Create Snapshot (Pull)").

`PATCH` from the adapter to the core at the `/snapshots/{xid}` route. The request body must include `details`, `summary`, and `value`.

### Schemas

Schemas are useful for oracles to advertise what services they offer, without specifying every detail. For instance, if an oracle offers stock prices, it can write a schema stating it only needs a stock ticker passed to it, and does not need to specify each data point it could possibly offer.

Additionally, the output of an oracle must be predictable, so the consumer can know how the will receive data even if they don't know what the data will be.

In order for the core to reliably pass data between blockchains, serivces, and adapters, the format data needs to be predictable. The Smart Oracles protocol currently does that trhough a series of [JSON Schemas](http://json-schema.org/). See the [Smart Oracles Specification](https://github.com/smartoracles/spec) for more details.

If an input schema is specified for an adapter, the core will validate all assignment data against the schema before passing it to an adapter. Similarly, the output specified in a snapshot's `details` field will be validated against the output schema of the adapter.


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
