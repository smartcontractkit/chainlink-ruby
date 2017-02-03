class AddHeadersJsonToJsonAdapters < ActiveRecord::Migration

  def change
    add_column :json_adapters, :headers_json, :text
    add_column :json_adapters, :basic_auth_password, :string
    add_column :json_adapters, :basic_auth_username, :string
  end

end
