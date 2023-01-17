class CreateKeywords < ActiveRecord::Migration[7.0]
  def change
    create_table :keywords do |t|
      t.string :open_filename
      t.string :save_filename
      t.integer :number
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
