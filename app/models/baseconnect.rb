class Baseconnect < ApplicationRecord
  with_options presence: true do
    validates :base_name
    validates :base_url, format: /\A#{URI::regexp(%w(http https))}\z/
  end
  has_one_attached :csv_file
  belongs_to :user
  def self.search(search)
    if search != ""
      Baseconnect.where(['base_name LIKE(?) OR base_url LIKE(?)', "%#{search}%", "%#{search}%"])
    else
      Baseconnect.all
    end
  end
end
