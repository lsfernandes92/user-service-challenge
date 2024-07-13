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
  end

  describe 'when using scope' do
    before { create_list(:user, 2) }

    let(:users_ids) { User.ids }
    
    context '.most_recently' do
      let(:last_user_created) { User.order(created_at: :desc).first }

      it 'returns users sorted by creation date (most recent first)' do
        expect(User.most_recently(users_ids).first).to eq last_user_created
      end

      it 'return nil when no id passed' do
        expect(User.most_recently([]).first).to eq nil
      end
    end

    context '.by_email' do
      let(:first_user) { User.first }
      let(:user_email) { first_user.email }

      it 'returns users by a given email' do
        expect(User.by_email(user_email).first).to eq first_user
      end

      it 'returns nil with invalid email' do
        expect(User.by_email('foo@email.com').first).to eq nil
      end
    end

    context '.by_full_name' do
      let(:first_user) { User.first }
      let(:second_user) { User.last }
      let(:user_full_name) { first_user.full_name }

      it 'returns users by a given full_name' do
        expect(User.by_full_name(user_full_name).first).to eq first_user
      end

      it 'returns users with the same full_name' do
        first_user.full_name = 'Foo name'
        second_user.full_name = 'Foo name'

        first_user.save
        second_user.save

        expect(User.by_full_name('Foo name').count).to eq 2
        expect(User.by_full_name('Foo name').first.id).to eq first_user.id
        expect(User.by_full_name('Foo name').last.id).to eq second_user.id
      end
      
      it 'returns nil with invalid full_name' do
        expect(User.by_full_name('foo name').first).to eq nil
      end
    end

    context '.by_metadata' do
      let(:first_user) { User.first }
      let(:user_metadata) { first_user.metadata }
      
      it 'returns users by a given full_name' do
        expect(User.by_metadata(user_metadata).first).to eq first_user
      end

      it 'return nil with invalid metadata' do
        expect(User.by_metadata('foo metadata').first).to eq nil
      end
    end
  end

  describe '#as_json' do
    before { create(:user) }

    let(:user_hash) { User.first.as_json }
    let(:desired_user_attributes) do
      %w[ email phone_number full_name key account_key metadata ]
    end

    it 'returns only the desirable atributes for the user' do
      expect(user_hash.keys).to match desired_user_attributes
    end
  end

  describe '.generate_random_sanitized_metadata' do
    it 'returns random sanitized metadata' do
      expect(User.generate_random_sanitized_metadata).not_to be_blank
      expect(User.generate_random_sanitized_metadata).to be_a String
    end
  end
end