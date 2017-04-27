class CreateJsonReceivers < ActiveRecord::Migration

  def change
    create_table :json_receivers do |t|
      t.string :xid
      t.string :path_json

      t.timestamps null: false
    end
  end

end
