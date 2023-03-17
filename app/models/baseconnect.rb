class Baseconnect < ApplicationRecord
  with_options presence: true do
    validates :name
    validates :url, format: /\A#{URI::regexp(%w(http https))}\z/
  end
  has_one_attached :csv_file
  belongs_to :user
  def self.search(search)
    if search != ""
      Baseconnect.where(['name LIKE(?) OR url LIKE(?)', "%#{search}%", "%#{search}%"])
    else
      Baseconnect.all
    end
  end
end
