require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'when routing to' do
    describe 'GET #index' do
      it 'routes to the index action' do
        expect(get: '/users').to route_to('users#index')
      end
    end
  end
end