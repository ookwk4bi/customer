class RenameBaseNameColumnToBaseconnects < ActiveRecord::Migration[7.0]
  def change
    rename_column :baseconnects, :base_name, :name
  end
end
