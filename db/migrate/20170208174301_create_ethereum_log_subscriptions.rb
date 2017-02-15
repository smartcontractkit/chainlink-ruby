class CreateEthereumLogSubscriptions < ActiveRecord::Migration

  def change
    create_table :ethereum_log_subscriptions do |t|
      t.integer :owner_id
      t.string :owner_type
      t.string :account
      t.string :xid
      t.datetime :end_at

      t.timestamps
    end
  end

end
