require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe 'GET #index' do
    let(:first_user) { User.last }

    before { create(:user); create(:user) }

    it 'returns status code 200' do
      get api_users_path

      expect(response).to have_http_status(200)
    end

    it 'responds with users' do
      get api_users_path

      expect(response_body['users'].first['email']).to eq(first_user.email)
      expect(response_body['users'].first['phone_number']).to eq(first_user.phone_number)
      expect(response_body['users'].first['full_name']).to eq(first_user.full_name)
      expect(response_body['users'].first['password']).to eq(first_user.password)
      expect(response_body['users'].first['key']).to eq(first_user.key)
      expect(response_body['users'].first['account_key']).to eq(first_user.account_key)
      expect(response_body['users'].first['metadata']).to eq(first_user.metadata)
    end
  end

  private

    def response_body
      JSON.parse(response.body)
    end
end