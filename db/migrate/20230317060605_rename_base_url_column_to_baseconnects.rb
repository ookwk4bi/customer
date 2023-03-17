class RenameBaseUrlColumnToBaseconnects < ActiveRecord::Migration[7.0]
  def change
    rename_column :baseconnects, :base_url, :url
  end
end
