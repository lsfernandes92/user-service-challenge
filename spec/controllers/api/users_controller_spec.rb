require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do
  describe 'when routing to' do
    describe 'GET /api/users' do
      it 'routes to the api/users#index' do
        expect(get: '/api/users').to route_to('api/users#index')
      end
    end

    describe 'POST /api/users' do
      it 'routes to the api/users#create' do
        expect(post: '/api/users').to route_to('api/users#create')
      end
    end
  end
end