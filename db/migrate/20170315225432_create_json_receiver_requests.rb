class CreateJsonReceiverRequests < ActiveRecord::Migration
  def change
    create_table :json_receiver_requests do |t|
      t.integer :json_receiver_id
      t.text :data_json

      t.timestamps null: false
    end
  end
end
