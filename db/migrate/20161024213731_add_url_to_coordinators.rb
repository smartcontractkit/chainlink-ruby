class AddUrlToCoordinators < ActiveRecord::Migration
  def change
    add_column :coordinators, :url, :string
  end
end
