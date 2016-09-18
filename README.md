# Smart Oracle Core

A ruby implementation of a core node running the [Smart Oracles Protocol](https://github.com/pivotal/vim-config/commits/master). The core provides a simple API for creating adapters to deal with various blockchains and off-chain services. Logic including key management, scheduling, and connectivity is consolidated in the core, so the adapter logic can be kept be focused on elsewhere. If you require finer grained control than what is provided, this logic can be controlled at the adapter level.

## Setup

### Configuration

The configuration settings for Nayru are stored in the `.env` file. See `.env.example` for the list of required fields.

### Database

Most of information, by default, is stored in Postgres. You'll need an instance of Postgres v9.3 or above. This can run on the same machine as the node, but if run in a container, it should be kept outside the container.

## Development

### Building an Adapter

Building a custom adapter to for the core is simple. There are a minimum of three restful API calls to create, but more can be added for greater control and clarity. All API calls must be authenticated.

#### API Calls

##### Required API Calls

###### Create Assignment

Used to create a new piece of work for an adapter.

`POST` to `/assignments` including keys `xid`, `end_at`, and `data`.

Response fields:
  - `xid`: String. The ID provided in the request to create the assignment.

###### Create Snapshot (Pull)

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

###### Delete Assignment

Used to indicate the end of an assignment.

`DELETE` to `/assignments/{xid}/snapshots` which additionally includes the assignment's `xid` in the body.

Response fields:
  - `status`: String(optional). The final status of the assignment.
  - `xid`: String. A new ID to identify the snapshot by.

##### Optional API calls

###### Create Snapshot (Push)

Used for updates that are pushed, or scheduled outside of the core.

`POST` from the adapter to the core at the `/snapshots` route. The request body must include `xid`, `details`, `summary`, and `value`.

###### Update Snapshot (Push)

Used to update unfulfilled snapshots(see "Create Snapshot (Pull)").

`PATCH` from the adapter to the core at the `/snapshots/{xid}` route. The request body must include `details`, `summary`, and `value`.


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
