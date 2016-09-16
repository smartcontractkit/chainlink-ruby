class CreateCustomExpectations < ActiveRecord::Migration
  def change
    create_table :custom_expectations do |t|
      t.string :comparison
      t.string :endpoint
      t.string :fields
      t.string :final_value

      t.timestamps
    end
  end
end
