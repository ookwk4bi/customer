class Keyword < ApplicationRecord
  with_options presence: true do
    # validates :open_filename, format: { with: /\A[ぁ-んァ-ン一-龥]/ }
    validates :save_filename, format: { with: /\A[ぁ-んァ-ン一-龥]/ }
    # validates :number, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
    # format: { with: /\A[0-9]+\z/ }
  end
  # csvファイルのみ登録できるようにする処理に必要
  has_one_attached :csv_file
  has_one_attached :open_filename
  validate :csv_file_must_be_csv
  belongs_to :user
  def self.search(search)
    if search != ""
      Keyword.where(['save_filename LIKE(?)',"%#{search}%"])
    else
      Keyword.all
    end
  end

  # csvファイルのみ登録できるようにする処理
  def csv_file_must_be_csv
    if open_filename.attached? && !open_filename.content_type.in?(%w(text/csv))
      errors.add(:open_filename, 'はCSVファイルのみアップロード可能です。')
    end
  end
end
