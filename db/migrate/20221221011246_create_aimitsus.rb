class CreateAimitsus < ActiveRecord::Migration[7.0]
  def change
    create_table :aimitsus do |t|
      t.string :aimitsu_name, null: false
      t.string :aimitsu_url, null: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
