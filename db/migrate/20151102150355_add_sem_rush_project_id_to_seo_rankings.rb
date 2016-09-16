class AddSemRushProjectIdToSeoRankings < ActiveRecord::Migration
  def change
    add_column :seo_rankings, :sem_rush_project_id, :integer
  end
end
