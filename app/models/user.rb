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
    uniqueness: true, unless: -> { account_key.nil? }

  before_validation :generate_key, on: :create
  after_validation :generate_hash_salt_password, on: :create
  after_commit :generate_account_key, on: :create

  scope :most_recently, -> (ids) { User.where(id: ids).order(created_at: :desc) }
  scope :by_email, -> (email) { where(email: email) }
  scope :by_full_name, -> (full_name) { where(full_name: full_name) }
  scope :by_metadata, -> (metadata) { where(metadata: metadata) }

  def as_json(options = {})
    super(except: %w[id password created_at updated_at])
  end

  def self.generate_random_sanitized_metadata
    "
      #{Faker::Gender.type}, 
      age #{rand(1..100)}, 
      #{%w[ employed unemployed ].sample}, 
      #{Faker::Educator.degree}
    ".strip.gsub(/\s+/, ' ')
  end

  private

    def generate_key
      self.key = Faker::Internet.password(min_length: 100, max_length: 100)
    end

    def generate_hash_salt_password
      user_password = self.password
      hash_password = Argon2::Password.create(user_password)
      self.password = hash_password
    end

    def generate_account_key
      GatherAccountKeyJob.perform_in(Time.now, self.email, self.key)
    end
end