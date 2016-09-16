class AddExpectationToTerms < ActiveRecord::Migration
  def change
    add_column :terms, :expectation_id, :integer
    add_column :terms, :expectation_type, :string
  end
end
