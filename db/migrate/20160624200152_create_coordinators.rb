class CreateCoordinators < ActiveRecord::Migration
  def change
    create_table :coordinators do |t|
      t.string :key
      t.string :secret

      t.timestamps
    end
  end
end
