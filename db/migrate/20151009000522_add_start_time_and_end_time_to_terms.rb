class AddStartTimeAndEndTimeToTerms < ActiveRecord::Migration
  def change
    add_column :terms, :start_at, :datetime
    add_column :terms, :end_at, :datetime
  end
end
