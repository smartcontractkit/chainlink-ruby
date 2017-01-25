class RenameInputAdaptersToExternalAdapters < ActiveRecord::Migration
  def change
    rename_table :input_adapters, :external_adapters
    Assignment.where("adapter_type = 'InputAdapter'")
      .update_all(adapter_type: 'ExternalAdapter')
  end
end
