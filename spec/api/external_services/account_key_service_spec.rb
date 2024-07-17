# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::Api::ExternalServices::AccountKeyService do
  describe '#gather_account_key', :vcr do
    let(:email) { 'user@example.com' }
    let(:key) { '72ae25495a7981c40622d49f9a52e4f1565c90f048f59027bd9c8c8900d5c3d8' }
    let(:response) { described_class.gather_account_key(email: email, key: key) }

    context 'when correct data provided' do
      it 'returns account_key as string' do
        expect(response).to be_a String
      end

      it 'returns json object with error' do
        expect(response).to be_a Hash
        expect(response).to match({
                                    message: '422 Unprocessable Entity',
                                    error: 422
                                  })
      end
    end

    context 'when email is blank' do
      let(:email) { '' }

      it 'returns 422 Unprocessable Entity' do
        expect(response).to be_a(Hash)
        expect(response).to match({
                                    message: '422 Unprocessable Entity',
                                    error: 422
                                  })
      end

      it 'logs error message' do
        allow(Rails.logger).to receive(:error)

        described_class.gather_account_key(email: email, key: key)

        expect(Rails.logger).to have_received(:error).with('!!! Something went wrong with the POST request')
        expect(Rails.logger).to have_received(:error).with('!!! It fails with error: 422')
        expect(Rails.logger).to have_received(:error).with('!!! And with message: 422 Unprocessable Entity')
      end
    end

    context 'when key is blank' do
      let(:key) { '' }

      it 'returns 422 Unprocessable Entity' do
        expect(response).to be_a(Hash)
        expect(response).to match({
                                    message: '422 Unprocessable Entity',
                                    error: 422
                                  })
      end

      it 'logs error message' do
        allow(Rails.logger).to receive(:error)

        described_class.gather_account_key(email: email, key: key)

        expect(Rails.logger).to have_received(:error).with('!!! Something went wrong with the POST request')
        expect(Rails.logger).to have_received(:error).with('!!! It fails with error: 422')
        expect(Rails.logger).to have_received(:error).with('!!! And with message: 422 Unprocessable Entity')
      end
    end
  end

  describe '#request_succeed?', :vcr do
    let(:email) { 'user@example.com' }
    let(:key) { '72ae25495a7981c40622d49f9a52e4f1565c90f048f59027bd9c8c8900d5c3d8' }
    let(:request_succeed?) { described_class.request_succeed? }

    before { described_class.gather_account_key(email: email, key: key) }

    it 'returns true when account key service succeed' do
      expect(request_succeed?).to eq true
    end

    it 'returns false when account key service fails' do
      expect(request_succeed?).to eq false
    end
  end
end
