class CreateSeoRankings < ActiveRecord::Migration
  def change
    create_table :seo_rankings do |t|
      t.integer :placement
      t.integer :seo_expectation_id

      t.timestamps
    end
  end
end
