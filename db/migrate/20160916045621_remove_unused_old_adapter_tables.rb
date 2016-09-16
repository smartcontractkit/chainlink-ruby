class RemoveUnusedOldAdapterTables < ActiveRecord::Migration
  def up
    remove_column :key_pairs, :encrypted_old_private_key, :string
    drop_table :bitcoin_addresses
    drop_table :bitcoin_outputs
    drop_table :bitcoin_output_payments
    drop_table :bitcoin_transactions
    drop_table :block_cypher_notifications
    drop_table :payments
    drop_table :payment_expectations
    drop_table :sem_rush_projects
    drop_table :seo_expectations
    drop_table :seo_rankings
  end

  def down
    add_column :key_pairs, :encrypted_old_private_key, :string

    create_table "bitcoin_addresses", force: :cascade do |t|
      t.string   "location"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "bcy_id"
      t.string   "bcy_auth_key"
    end

    create_table "bitcoin_output_payments", force: :cascade do |t|
      t.integer  "bitcoin_output_id"
      t.integer  "payment_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "bitcoin_outputs", force: :cascade do |t|
      t.integer  "bitcoin_address_id"
      t.integer  "bitcoin_transaction_id"
      t.integer  "tx_index"
      t.decimal  "satoshis",               precision: 16
      t.datetime "created_at"
      t.datetime "updated_at"
      t.decimal  "usd_cents",              precision: 24, scale: 8
    end

    create_table "bitcoin_transactions", force: :cascade do |t|
      t.string   "txid"
      t.integer  "confirmations"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "usd_price"
    end

    create_table "block_cypher_notifications", force: :cascade do |t|
      t.string   "subject_type"
      t.integer  "subject_id"
      t.string   "owner_type"
      t.integer  "owner_id"
      t.boolean  "active",       default: true
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "payment_expectations", force: :cascade do |t|
      t.integer  "bitcoin_address_id"
      t.integer  "cents"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "payments", force: :cascade do |t|
      t.integer  "payment_expectation_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "bitcoin_transaction_id"
    end

    create_table "sem_rush_projects", force: :cascade do |t|
      t.integer  "seo_expectation_id"
      t.string   "name"
      t.string   "status"
      t.string   "xid"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "seo_expectations", force: :cascade do |t|
      t.string   "search_term"
      t.string   "domain"
      t.string   "locale"
      t.integer  "minimum_rank"
      t.integer  "maximum_rank"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "seo_rankings", force: :cascade do |t|
      t.integer  "placement"
      t.integer  "seo_expectation_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "sem_rush_project_id"
    end
  end
end
