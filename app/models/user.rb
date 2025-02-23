class User < ApplicationRecord

    has_secure_password
    
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :pass, presence: true, length: { minimum: 6 }

    has_many :sessions, dependent: :destroy
    has_many :recipes, dependent: :destroy
    has_many :favorites, dependent: :destroy
end
