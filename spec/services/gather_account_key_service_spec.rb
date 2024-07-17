require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe GatherAccountKeyService, :vcr do
  subject { described_class.new('foo@email.com', 'randomkey') }

  describe '#perform' do
    context 'when the user exists' do
      before do
        allow(User).to receive(:find_by!).and_return(user)
        allow(subject).to receive(:account_key_service).and_return(
          double('AccountKeyService', gather_account_key: 'external_key')
        )
      end

      let!(:user) { create(:user, :without_account_key) }
    
      it 'finds the user by email' do
        expect(User).to receive(:find_by!)
          .with(email: 'foo@email.com')
          .and_return(user)

        subject.perform
      end

      it 'sets the user account_key and saves the user' do
        expect(user).to receive(:account_key=).with('external_key')
        expect(user).to receive(:save!)

        subject.perform
      end
    end

    context 'with user not found' do
      before do
        allow(User).to receive(:find_by!)
          .with(email: 'foo@email.com')
          .and_raise(ActiveRecord::RecordNotFound)
      end
    
      it 'raises an error' do
        expect { subject.perform }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end