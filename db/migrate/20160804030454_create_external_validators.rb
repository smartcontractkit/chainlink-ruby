class CreateExternalValidators < ActiveRecord::Migration
  def change
    create_table :validators do |t|
      t.string :url
      t.string :type
      t.text :json_schema

      t.timestamps
    end
  end
end
