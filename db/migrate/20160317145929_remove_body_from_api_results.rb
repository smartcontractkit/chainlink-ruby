class RemoveBodyFromApiResults < ActiveRecord::Migration
  def change
    remove_column :api_results, :body, :text
  end
end
