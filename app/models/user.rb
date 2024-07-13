class User < ApplicationRecord
  validates :email,
    length: { maximum: 200 },
    presence: true,
    uniqueness: true,
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number,
    length: { maximum: 20 },
    presence: true,
    uniqueness: true
  validates :full_name, length: { maximum: 200 }
  validates :password,
    length: { maximum: 100 },
    presence: true
  validates :key,
    length: { maximum: 100 },
    presence: true,
    uniqueness: true  
  validates :account_key,
    length: { maximum: 100 },
    uniqueness: true

  scope :most_recently, -> (ids) { User.where(id: ids).order(created_at: :desc) }

  def as_json(options = {})
    super(except: %w[id created_at updated_at])
  end

  def self.generate_random_metadata
    "
      #{Faker::Gender.type}, 
      age #{rand(1..100)}, 
      #{%w[ employed unemployed ].sample}, 
      #{Faker::Educator.degree}
    ".strip.gsub(/\s+/, ' ')
  end
end