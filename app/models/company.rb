class Company < ApplicationRecord
  validates :name, presence: true
  validates :address, presence: true
  validates :url, presence: true
  require 'csv'
  belongs_to :user
  # CSVエクスポート出力
  def self.csv_attributes
    ["name", "address","url"]
  end

  def self.generate_csv(user)
    CSV.generate(headers: true) do |csv|
      csv << csv_attributes
      where(user: user).each do |company|
        csv << csv_attributes.map{|attr| company.send(attr)}
      end
    end
  end

  # 検索機能実装
  def self.search(search)
    if search != ""
      Company.where(['name LIKE(?) OR address LIKE(?) OR url LIKE(?)', "%#{search}%", "%#{search}%", "%#{search}%"])
    else
      Company.all
    end
  end
end
