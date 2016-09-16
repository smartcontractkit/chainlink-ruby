class CreateBlockCypherNotifications < ActiveRecord::Migration
  def change
    create_table :block_cypher_notifications do |t|
      t.string   :subject_type
      t.integer  :subject_id
      t.string   :owner_type
      t.integer  :owner_id
      t.boolean  :active, default: true

      t.timestamps
    end
  end
end
