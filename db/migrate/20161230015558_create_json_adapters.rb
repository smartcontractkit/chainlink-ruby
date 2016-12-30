class CreateJsonAdapters < ActiveRecord::Migration
  def change
    create_table :json_adapters do |t|
      t.text :url
      t.text :field_list
      t.string :request_type

      t.timestamps
    end
  end
end
