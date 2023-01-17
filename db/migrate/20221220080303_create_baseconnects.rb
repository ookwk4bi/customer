class CreateBaseconnects < ActiveRecord::Migration[7.0]
  def change
    create_table :baseconnects do |t|
      t.string :base_name, null: false
      t.string :base_url, null: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
