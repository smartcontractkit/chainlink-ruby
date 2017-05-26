class EncryptPrivateKeys < ActiveRecord::Migration

  def up
    add_column :key_pairs, :encrypted_private_key, :text

    password = ENV['PRIVATE_KEY_PASSWORD'].to_s
    KeyPair.find_each do |key_pair|
      decrypted = key_pair.read_attribute(:private_key)
      encrypted = Eth::Key.encrypt decrypted, password
      key_pair.update_attributes! encrypted_private_key: encrypted
    end

    remove_column :key_pairs, :private_key, :text
  end

  def down
    add_column :key_pairs, :private_key, :string

    KeyPair.find_each do |key_pair|
      key_pair.update_column :private_key, key_pair.private_key
    end

    remove_column :key_pairs, :encrypted_private_key, :text
  end

end
