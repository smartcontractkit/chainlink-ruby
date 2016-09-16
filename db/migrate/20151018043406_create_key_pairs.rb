class CreateKeyPairs < ActiveRecord::Migration
  def change
    create_table :key_pairs do |t|
      t.string :owner_type
      t.integer :owner_id
      t.string :public_key
      t.string :encrypted_private_key

      t.timestamps
    end
  end
end
