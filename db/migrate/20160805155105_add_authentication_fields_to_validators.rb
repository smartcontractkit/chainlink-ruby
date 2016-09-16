class AddAuthenticationFieldsToValidators < ActiveRecord::Migration
  def change
    add_column :validators, :username, :string
    add_column :validators, :password, :string
  end
end
