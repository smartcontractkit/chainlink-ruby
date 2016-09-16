class CreateEscrowOutcomes < ActiveRecord::Migration
  def change
    create_table :escrow_outcomes do |t|
      t.integer :term_id
      t.string :result
      t.text :transaction_hex

      t.timestamps
    end
  end
end
