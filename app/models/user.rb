class User < ApplicationRecord
  GENDERS = %w[ male female lesbian gay bisexual pansexual asexual transgender non-binary queer ]
  EMPLOYMENT_STATUSES = %w[ employed unemployed ]
  EDUCATIONAL_LEVELS = %w[ 
    no-formal-educated
    primary-educated
    secondary-educated
    bachelors-educated
    masters-educated
    doctorate-educated
  ]
  AGE_REGEX = /\Aage\s+(\d{1,2}|100)\z/

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
  validates :gender,
    allow_nil: true,
    inclusion: { in: GENDERS, message: "must be one of the following: #{GENDERS}" }
  validates :employment_status,
    allow_nil: true,
    inclusion: { in: EMPLOYMENT_STATUSES, message: "must be one of the following: #{EMPLOYMENT_STATUSES}" }
  validates :educational_level,
    allow_nil: true,
    inclusion: { in: EDUCATIONAL_LEVELS, message: "must be one of the following: #{EDUCATIONAL_LEVELS}" }
  validates :age,
    allow_nil: true,
    format: { with: AGE_REGEX, message: "must be in the format 'age <NUMBER>' where number is between 0 and 100" }

  store :metadata, accessors: [ :gender, :age, :employment_status, :educational_level ]
  store_accessor :metadata

  scope :most_recently, -> { order(created_at: :asc) }

  def as_json(options = {})
    super(
      except: %w[id created_at updated_at]
    ).merge(metadata: sanitized_metadata)
  end

  def self.generate_random_metadata
    {
      gender: "#{User::GENDERS.sample}",
      age: "age #{rand(1..100)}",
      employment_status: "#{User::EMPLOYMENT_STATUSES.sample}",
      educational_level: "#{User::EDUCATIONAL_LEVELS.sample}"
    }
  end

  private

    def sanitized_metadata
      metadata.values.join(', ').strip.gsub(/\s+/, ' ')
    end
end