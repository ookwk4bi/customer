class Rekaizen < ApplicationRecord
  with_options presence: true do
    validates :rekaizen_name
    validates :rekaizen_url, format: { with: /\A(https?:\/\/)?(www\.)?rekaizen\.com\//, message: "は https://rekaizen.com/ が含まれている必要があります" }
    validates :rekaizen_url, format: /\A#{URI::regexp(%w(http https))}\z/
  end
  has_one_attached :csv_file
  belongs_to :user
  def self.search(search)
    if search != ""
      Rekaizen.where(['rekaizen_name LIKE(?) OR rekaizen_url LIKE(?)', "%#{search}%", "%#{search}%"])
    else
      Rekaizen.all
    end
  end
end
