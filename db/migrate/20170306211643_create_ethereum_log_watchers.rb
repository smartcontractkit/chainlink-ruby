class CreateEthereumLogWatchers < ActiveRecord::Migration
  def change
    create_table :ethereum_log_watchers do |t|
      t.string :address

      t.timestamps
    end
  end
end
