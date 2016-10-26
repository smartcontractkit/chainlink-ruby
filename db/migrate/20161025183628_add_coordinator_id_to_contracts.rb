class AddCoordinatorIdToContracts < ActiveRecord::Migration
  def change
    add_column :contracts, :coordinator_id, :integer
  end
end
