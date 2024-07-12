require 'rails_helper'

RSpec.describe Api::UsersController, type: :controller do
  describe 'when routing to' do
    describe 'GET #index' do
      it 'routes to the index action' do
        expect(get: '/api/users').to route_to('api/users#index')
      end
    end
  end
end