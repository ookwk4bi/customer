class Baseconnect < ApplicationRecord
  with_options presence: true do
    validates :name
    validates :url, format: { with: /\Ahttps:\/\/baseconnect\.in\/companies\//, message: "は https://baseconnect.in/companies/ で始まる必要があります。" }
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

