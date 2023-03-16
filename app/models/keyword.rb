class Keyword < ApplicationRecord
  with_options presence: true do
    # validates :open_filename, format: { with: /\A[ぁ-んァ-ン一-龥]/ }
    validates :save_filename, format: { with: /\A[ぁ-んァ-ン一-龥]/ }
    # validates :number, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
    # format: { with: /\A[0-9]+\z/ }
  end
  has_one_attached :csv_file
  
  belongs_to :user
  def self.search(search)
    if search != ""
      Keyword.where(['save_filename LIKE(?)',"%#{search}%"])
    else
      Keyword.all
    end
  end
end
