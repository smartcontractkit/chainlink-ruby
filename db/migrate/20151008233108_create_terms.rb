class CreateTerms < ActiveRecord::Migration
  def change
    create_table :terms do |t|
      t.integer :contract_id
      t.string :name
      t.string :tracking

      t.timestamps
    end
  end
end
