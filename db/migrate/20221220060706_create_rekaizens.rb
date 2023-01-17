class CreateRekaizens < ActiveRecord::Migration[7.0]
  def change
    create_table :rekaizens do |t|
      t.string :rekaizen_name, null: false
      t.string :rekaizen_url, null:false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
