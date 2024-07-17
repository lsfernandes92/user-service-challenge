# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Request do
  describe '#post', :vcr do
    let(:base_url) { ::Api::ExternalServices::AccountKeyService::BASE_URL }
    let(:url) { "#{base_url}/v1/account" }
    let(:payload) do
      {
        email: 'foo@email.com',
        key: 'r4nd0mk3y'
      }
    end
    let(:headers) { { content_type: 'application/json' } }
    let(:response) { described_class.post(url, payload, headers) }

    context 'with the correct data provide' do
      it 'returns json object with email and account_key' do
        expect(response).to be_a(Hash)
        expect(response.keys).to match_array(%w[email account_key])
        expect(response[:email]).to be_a(String)
        expect(response[:account_key]).to be_a(String)
      end
    end

    context 'with the wrong data provided' do
      context 'when the URL is wrong' do
        let(:url) { 'https://www.foo.com/' }

        it 'returns a json error object' do
          expect(response).to be_a(Hash)
          expect(response).to match({
            message: 'SSL_connect returned=1 errno=0 state=error: certificate verify failed (self signed certificate)',
            error: nil
          })
        end

        it 'logs error message' do
          allow(Rails.logger).to receive(:error)

          described_class.post(url, payload, headers)

          expect(Rails.logger).to have_received(:error).with('!!! It seems like the given URL is not correct')
        end
      end

      context 'when the payload is wrong' do
        let(:payload) do
          {
            "email": 'foo@email.com',
            "password": 'foopassword'
          }
        end

        it 'returns a json error object' do
          expect(response).to be_a(Hash)
          expect(response).to match({ message: '422 Unprocessable Entity', error: 422 })
        end

        it 'logs error message' do
          allow(Rails.logger).to receive(:error)

          described_class.post(url, payload, headers)

          expect(Rails.logger).to have_received(:error).with('!!! Something went wrong with the POST request')
          expect(Rails.logger).to have_received(:error).with('!!! It fails with error: 422')
          expect(Rails.logger).to have_received(:error).with('!!! And with message: 422 Unprocessable Entity')
        end
      end

      context 'when the header is wrong' do
        let(:headers) { { content_type: 'application/pdf' } }

        it 'returns a json error object' do
          expect(response).to be_a(Hash)
          expect(response).to match({ message: '502 Bad Gateway', error: 502 })
        end

        it 'logs error message' do
          allow(Rails.logger).to receive(:error)

          described_class.post(url, payload, headers)

          expect(Rails.logger).to have_received(:error).with('!!! Something went wrong with the POST request')
          expect(Rails.logger).to have_received(:error).with('!!! It fails with error: 502')
          expect(Rails.logger).to have_received(:error).with('!!! And with message: 502 Bad Gateway')
        end
      end
    end
  end
end
