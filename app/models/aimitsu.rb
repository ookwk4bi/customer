class Aimitsu < ApplicationRecord
  with_options presence: true do
    validates :aimitsu_name
    validates :aimitsu_url, format: { with: /\A(https?:\/\/)?(www\.)?imitsu\.jp\//, message: "は https://imitsu.jp/ が含まれている必要があります" }
    validates :aimitsu_url, format: /\A#{URI::regexp(%w(http https))}\z/
  end
  has_one_attached :csv_file
  belongs_to :user
  def self.search(search)
    if search != ""
      Aimitsu.where(['aimitsu_name LIKE(?) OR aimitsu_url LIKE(?)', "%#{search}%", "%#{search}%"])
    else
      Aimitsu.all
    end
  end
end
