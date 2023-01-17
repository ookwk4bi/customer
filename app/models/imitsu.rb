class Imitsu < ApplicationRecord
  with_options presence: true do
    validates :imitsu_name
    validates :imitsu_url, format: /\A#{URI::regexp(%w(http https))}\z/
  end
  has_one_attached :csv_file
  belongs_to :user
  # 検索機能実装
  def self.search(search)
    if search != ""
      Imitsu.where(['imitsu_name LIKE(?) OR imitsu_url LIKE(?)', "%#{search}%", "%#{search}%"])
    else
      Imitsu.all
    end
  end
end
