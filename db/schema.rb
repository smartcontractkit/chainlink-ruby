# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170210205524) do

  create_table "adapter_snapshots", force: :cascade do |t|
    t.integer  "assignment_snapshot_id"
    t.integer  "subtask_id"
    t.text     "description"
    t.text     "description_url"
    t.text     "details_json"
    t.boolean  "fulfilled",              default: false
    t.text     "summary"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "progress"
    t.string   "status"
  end

  create_table "api_results", force: :cascade do |t|
    t.text     "parsed_value"
    t.integer  "custom_expectation_id"
    t.boolean  "success",               default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assignment_requests", force: :cascade do |t|
    t.integer  "assignment_id"
    t.string   "body_hash"
    t.text     "body_json"
    t.string   "signature"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assignment_scheduled_updates", force: :cascade do |t|
    t.integer  "assignment_id"
    t.datetime "run_at"
    t.boolean  "scheduled",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assignment_schedules", force: :cascade do |t|
    t.integer  "assignment_id"
    t.string   "minute"
    t.string   "hour"
    t.string   "day_of_month"
    t.string   "month_of_year"
    t.string   "day_of_week"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start_at"
    t.datetime "end_at"
  end

  create_table "assignment_snapshots", force: :cascade do |t|
    t.string   "xid"
    t.text     "value"
    t.text     "status"
    t.text     "details_json"
    t.boolean  "fulfilled",       default: false
    t.integer  "assignment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "summary"
    t.text     "description"
    t.text     "description_url"
    t.string   "progress"
    t.integer  "adapter_index"
  end

  create_table "assignment_types", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.text     "json_schema"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "unscheduled", default: false
  end

  create_table "assignments", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "xid"
    t.datetime "start_at"
    t.datetime "end_at"
    t.string   "status"
    t.integer  "coordinator_id"
  end

  create_table "contracts", force: :cascade do |t|
    t.string   "xid"
    t.text     "json_body"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "coordinator_id"
  end

  create_table "coordinators", force: :cascade do |t|
    t.string   "key"
    t.string   "secret"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
  end

  create_table "custom_expectations", force: :cascade do |t|
    t.string   "comparison"
    t.string   "endpoint"
    t.string   "field_list"
    t.string   "final_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "escrow_outcomes", force: :cascade do |t|
    t.integer  "term_id"
    t.string   "result"
    t.text     "transaction_hex"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ethereum_accounts", force: :cascade do |t|
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "nonce",      default: 0
  end

  create_table "ethereum_bytes32_oracles", force: :cascade do |t|
    t.string   "address"
    t.string   "update_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ethereum_account_id"
  end

  create_table "ethereum_contract_templates", force: :cascade do |t|
    t.text     "code"
    t.text     "evm_hex"
    t.text     "json_abi"
    t.text     "solidity_abi"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "construction_gas"
    t.string   "read_address"
    t.string   "write_address"
    t.string   "adapter_name"
  end

  create_table "ethereum_contracts", force: :cascade do |t|
    t.string   "address"
    t.integer  "template_id"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "genesis_transaction_id"
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  create_table "ethereum_oracle_writes", force: :cascade do |t|
    t.integer  "oracle_id"
    t.string   "txid"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "oracle_type"
  end

  create_table "ethereum_oracles", force: :cascade do |t|
    t.text     "endpoint"
    t.text     "field_list"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ethereum_transactions", force: :cascade do |t|
    t.string   "txid"
    t.integer  "account_id"
    t.integer  "confirmations",           default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "raw_hex"
    t.integer  "nonce"
    t.string   "to"
    t.text     "data"
    t.integer  "value",         limit: 8
    t.integer  "gas_price",     limit: 8
    t.integer  "gas_limit"
  end

  create_table "ethereum_uint256_oracles", force: :cascade do |t|
    t.string   "address"
    t.string   "update_address"
    t.integer  "ethereum_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "external_adapters", force: :cascade do |t|
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assignment_type_id"
    t.string   "username"
    t.string   "password"
  end

  create_table "json_adapters", force: :cascade do |t|
    t.text     "url"
    t.text     "field_list"
    t.string   "request_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "headers_json"
    t.string   "basic_auth_password"
    t.string   "basic_auth_username"
  end

  create_table "key_pairs", force: :cascade do |t|
    t.string   "owner_type"
    t.integer  "owner_id"
    t.string   "public_key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "private_key"
  end

  create_table "subtasks", force: :cascade do |t|
    t.string   "adapter_type"
    t.integer  "adapter_id"
    t.integer  "assignment_id"
    t.integer  "index"
    t.text     "adapter_params_json"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "ready"
  end

  create_table "terms", force: :cascade do |t|
    t.integer  "contract_id"
    t.string   "name"
    t.string   "tracking"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "expectation_id"
    t.string   "expectation_type"
    t.string   "status"
  end

end
