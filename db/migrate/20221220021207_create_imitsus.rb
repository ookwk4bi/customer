class CreateImitsus < ActiveRecord::Migration[7.0]
  def change
    create_table :imitsus do |t|
      t.string :imitsu_name, null: false
      t.string :imitsu_url, null: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
