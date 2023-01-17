class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable

  validates :nickname, presence: true
  has_many :companies
  has_many :aimitsus
  has_many :baseconnects
  has_many :imitsus
  has_many :rekaizens
  has_many :keywords
end
