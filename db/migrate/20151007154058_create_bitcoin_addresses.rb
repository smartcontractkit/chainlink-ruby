class CreateBitcoinAddresses < ActiveRecord::Migration
  def change
    create_table :bitcoin_addresses do |t|
      t.string :location

      t.timestamps
    end
  end
end
