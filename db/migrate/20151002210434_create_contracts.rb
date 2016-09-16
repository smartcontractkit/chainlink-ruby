class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.string :xid
      t.text :json_body
      t.string :status

      t.timestamps
    end
  end
end
