# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe User, type: :model do
  subject { build(:user) }

  let(:first_user) { User.first }
  let(:last_user) { User.last }

  context 'when is being created' do
    let(:user_without_key) { build(:user, :without_key) }
    let(:user_without_account_key) { build(:user, :without_account_key) }

    it 'succeds with valid attributes' do
      expect(subject).to be_valid
      expect { subject.save }.to change { User.count }.by(1)
    end

    it 'generates the key automagically' do
      user_without_key.save!

      expect(last_user.key).not_to be_blank
      expect(last_user.key).to be_a String
      expect(last_user.key.length).to eq 100
    end

    it 'sets account_key to nil' do
      user_without_account_key.save!

      expect(last_user.account_key).to be_nil
    end

    it 'generates a salt password automagically' do
      subject.password = 'easypassword'
      subject.save!

      secure_password = User.last.password
      pass_verified = Argon2::Password.verify_password('easypassword', secure_password)
      expect(pass_verified).to eq true
    end

    it 'queues job to gather account key' do
      expect { user_without_account_key.save! }.to change(GatherAccountKeyJob.jobs, :size).by(1)
    end
  end

  context 'with validations' do
    context 'on email attribute' do
      it 'validates presence' do
        subject.email = ''

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ["Email can't be blank", 'Email is invalid']
        )
      end

      it 'validates maximum length' do
        subject.email = 'a' * 201

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ['Email is invalid', 'Email is too long (maximum is 200 characters)']
        )
      end

      it 'validates uniqueness' do
        create(:user, email: 'foo@gmail.com')
        subject.email = 'foo@gmail.com'

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ['Email has already been taken']
        )
      end

      it 'validates format' do
        subject.email = 'fooemail.whatever'

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ['Email is invalid']
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
          ['Phone number is too long (maximum is 20 characters)']
        )
      end

      it 'validates uniqueness' do
        create(:user, phone_number: '9999999999')
        subject.phone_number = '9999999999'

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ['Phone number has already been taken']
        )
      end
    end

    context 'on full_name attribute' do
      it 'validates maximum length' do
        subject.full_name = 'a' * 201

        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to match_array(
          ['Full name is too long (maximum is 200 characters)']
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
          ['Password is too long (maximum is 100 characters)']
        )
      end
    end

    context 'on key attribute' do
      context 'when a user is being reassign' do
        before { create(:user) }

        let(:already_taken_key) { last_user.key }

        it 'validates presence' do
          last_user.key = ''

          expect(last_user).not_to be_valid
          expect(last_user.errors.full_messages).to match_array(
            ["Key can't be blank"]
          )
        end

        it 'validates maximum length' do
          last_user.key = 'a' * 101

          expect(last_user).not_to be_valid
          expect(last_user.errors.full_messages).to match_array(
            ['Key is too long (maximum is 100 characters)']
          )
        end

        it 'validates uniqueness' do
          create(:user)
          first_user.key = already_taken_key

          expect(first_user).not_to be_valid
          expect(first_user.errors.full_messages).to match_array(
            ['Key has already been taken']
          )
        end
      end
    end

    context 'on account_key attribute' do
      context 'when a user is being reassign' do
        before { create(:user) }

        let(:already_taken_account_key) { last_user.account_key }

        it 'validates maximum length' do
          last_user.account_key = 'a' * 101

          expect(last_user).not_to be_valid
          expect(last_user.errors.full_messages).to match_array(
            ['Account key is too long (maximum is 100 characters)']
          )
        end

        it 'validates uniqueness' do
          create(:user)
          first_user.account_key = already_taken_account_key

          expect(first_user).not_to be_valid
          expect(first_user.errors.full_messages).to match_array(
            ['Account key has already been taken']
          )
        end

        it 'does not validate uniqueness on nil' do
          create(:user)
          first_user.account_key = nil

          expect(first_user).to be_valid
        end
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

      it 'returns nil when no id passed' do
        expect(User.most_recently([]).first).to eq nil
      end
    end

    context '.by_email' do
      let(:user_email) { first_user.email }

      it 'returns users by a given email' do
        expect(User.by_email(user_email).first).to eq first_user
      end

      it 'returns nil with invalid email' do
        expect(User.by_email('foo@email.com').first).to eq nil
      end
    end

    context '.by_full_name' do
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
      let(:user_metadata) { first_user.metadata }

      it 'returns users by a given full_name' do
        expect(User.by_metadata(user_metadata).first).to eq first_user
      end

      it 'returns nil with invalid metadata' do
        expect(User.by_metadata('foo metadata').first).to eq nil
      end
    end
  end

  describe '#as_json' do
    before { create(:user) }

    let(:user_hash) { User.first.as_json }
    let(:desired_user_attributes) do
      %w[email phone_number full_name key account_key metadata]
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
