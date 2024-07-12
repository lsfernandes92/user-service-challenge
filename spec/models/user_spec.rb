require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  context 'when is being created' do
    it 'succeds with valid attributes' do
      expect(subject).to be_valid
      expect{ subject.save }.to change { User.count }.by(1)
    end
  end

  context 'with validations' do
    context 'on email attribute' do
      it 'validates presence' do
        subject.email = ''

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ["Email can't be blank", "Email is invalid"]
        )
      end

      it 'validates maximum length' do
        subject.email = 'a' * 201

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ["Email is invalid", "Email is too long (maximum is 200 characters)"]
        )
      end
      
      it 'validates uniqueness' do
        create(:user, email: 'foo@gmail.com')
        subject.email = 'foo@gmail.com'

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ["Email has already been taken"]
        )
      end

      it 'validates format' do
        subject.email = 'fooemail.whatever'

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ["Email is invalid"]
        )
      end
    end

    context 'on phone_number attribute' do
      it 'validates presence' do
        subject.phone_number = ''

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ["Phone number can't be blank"]
        )
      end
      
      it 'validates maximum length' do
        subject.phone_number = 'a' * 21

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ["Phone number is too long (maximum is 20 characters)"]
        )
      end   
      
      it 'validates uniqueness' do
        create(:user, phone_number: '9999999999')
        subject.phone_number = '9999999999'

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ["Phone number has already been taken"]
        )
      end
    end

    context 'on full_name attribute' do
      it 'validates maximum length' do
        subject.full_name = 'a' * 201

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ["Full name is too long (maximum is 200 characters)"]
        )
      end
    end

    context 'on password attribute' do
      it 'validates presence' do
        subject.password = ''

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ["Password can't be blank"]
        )
      end
      
      it 'validates maximum length' do
        subject.password = 'a' * 101

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ["Password is too long (maximum is 100 characters)"]
        )
      end 
    end

    context 'on key attribute' do
      let(:already_taken_key) do
        Faker::Internet.password(min_length: 100, max_length: 100)
      end

      it 'validates presence' do
        subject.key = ''

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ["Key can't be blank"]
        )
      end
      
      it 'validates maximum length' do
        subject.key = 'a' * 101

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ["Key is too long (maximum is 100 characters)"]
        )
      end

      it 'validates uniqueness' do
        create(:user, key: already_taken_key)
        subject.key = already_taken_key

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ["Key has already been taken"]
        )
      end
    end

    context 'on account_key attribute' do
      let(:already_taken_account_key) do
        Faker::Internet.password(min_length: 100, max_length: 100)
      end

      it 'validates maximum length' do
        subject.account_key = 'a' * 101

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ["Account key is too long (maximum is 100 characters)"]
        )
      end

      it 'validates uniqueness' do
        create(:user, account_key: already_taken_account_key)
        subject.account_key = already_taken_account_key

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ["Account key has already been taken"]
        )
      end
    end

    context 'on gender metadata attribute' do
      it 'accepts nil' do
        subject.gender = nil

        expect(subject).to be_valid
        expect(subject.errors.full_messages).to be_empty
      end
      
      it 'validates valid format' do
        subject.gender = User::GENDERS.sample

        expect(subject).to be_valid
        expect(subject.errors.full_messages).to be_empty
      end

      it 'validates invalid format' do
        subject.gender = 'foo'

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array([
          "Gender must be one of the following: [\"male\", \"female\", \"lesbian\", \"gay\", \"bisexual\", \"pansexual\", \"asexual\", \"transgender\", \"non-binary\", \"queer\"]"
        ])
      end
    end

    context 'on employment_status metadata attribute' do
      it 'accepts nil' do
        subject.employment_status = nil

        expect(subject).to be_valid
        expect(subject.errors.full_messages).to be_empty
      end

      it 'validates valid format' do
        subject.employment_status = User::EMPLOYMENT_STATUSES.sample

        expect(subject).to be_valid
        expect(subject.errors.full_messages).to be_empty
      end

      it 'validates invalid format' do
        subject.employment_status = 'foo'

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array([
          "Employment status must be one of the following: [\"employed\", \"unemployed\"]"
        ])
      end
    end

    context 'on educational_level metadata attribute' do
      it 'accepts nil' do
        subject.educational_level = nil

        expect(subject).to be_valid
        expect(subject.errors.full_messages).to be_empty
      end

      it 'validates valid format' do
        subject.educational_level = User::EDUCATIONAL_LEVELS.sample

        expect(subject).to be_valid
        expect(subject.errors.full_messages).to be_empty
      end

      it 'validates invalid format' do
        subject.educational_level = 'foo'

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array([
          "Educational level must be one of the following: [\"no-formal-educated\", \"primary-educated\", \"secondary-educated\", \"bachelors-educated\", \"masters-educated\", \"doctorate-educated\"]"
        ])
      end
    end

    context 'on age metadata attribute' do
      it 'accepts nil' do
        subject.age = nil

        expect(subject).to be_valid
        expect(subject.errors.full_messages).to be_empty
      end

      it 'validates valid format' do
        subject.age = 'age 31'

        expect(subject).to be_valid
        expect(subject.errors.full_messages).to be_empty
      end

      it 'validates invalid format' do
        subject.age = 'foo'

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array([
          "Age must be in the format 'age <NUMBER>' where number is between 0 and 100"
        ])
      end
    end
  end
end