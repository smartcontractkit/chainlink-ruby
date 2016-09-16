class CreateSeoExpectations < ActiveRecord::Migration
  def change
    create_table :seo_expectations do |t|
      t.string :search_term
      t.string :domain
      t.string :locale
      t.integer :minimum_rank
      t.integer :maximum_rank

      t.timestamps
    end
  end
end
