class AddPrivateKeyToKeyPairs < ActiveRecord::Migration

  def change
    add_column :key_pairs, :private_key, :string
    rename_column :key_pairs, :encrypted_private_key, :encrypted_old_private_key
  end

end
