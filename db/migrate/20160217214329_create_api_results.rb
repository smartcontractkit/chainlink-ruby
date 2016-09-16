class CreateApiResults < ActiveRecord::Migration
  def change
    create_table :api_results do |t|
      t.text :body
      t.text :parsed_value
      t.integer :custom_expectation_id
      t.boolean :success, default: false

      t.timestamps
    end
  end
end
