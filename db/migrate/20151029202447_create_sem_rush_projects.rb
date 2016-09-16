class CreateSemRushProjects < ActiveRecord::Migration
  def change
    create_table :sem_rush_projects do |t|
      t.integer :seo_expectation_id
      t.string :name
      t.string :status
      t.string :xid

      t.timestamps
    end
  end
end
