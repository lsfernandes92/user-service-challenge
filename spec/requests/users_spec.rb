require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe 'GET /api/users' do
    let(:first_user_created) { User.order(created_at: :desc).last }
    let(:last_user_created) { User.order(created_at: :desc).first }

    before { create_list(:user, 2) }

    it 'returns status code 200' do
      get api_users_path

      expect(response).to have_http_status(200)
    end

    it 'responds with users' do
      get api_users_path

      expect(response_body['users'].first['email']).to eq(last_user_created.email)
      expect(response_body['users'].first['phone_number']).to eq(last_user_created.phone_number)
      expect(response_body['users'].first['full_name']).to eq(last_user_created.full_name)
      expect(response_body['users'].first['key']).to eq(last_user_created.key)
      expect(response_body['users'].first['account_key']).to eq(last_user_created.account_key)
      expect(response_body['users'].first['metadata']).to eq(last_user_created.metadata)
    end

    it 'responds with users sorted by creation date (most recent first)' do
      get api_users_path

      expect(response_body['users'].first['full_name']).to eq(last_user_created.full_name)
    end

    context 'request with query params' do
      context 'passing the email' do
        it 'returns user with a given email' do
          get api_users_path, params: { email: last_user_created.email }

          expect(request.query_parameters).to include(:email)
          expect(response_body['users'].count).to eq 1
          expect(response_body['users'].first['full_name']).to eq(last_user_created.full_name)
        end
        
        it 'returns nil with non existed email' do
          get api_users_path, params: { email: 'foo@email.com' }

          expect(request.query_parameters).to include(:email)
          expect(response_body['users'].count).to eq 0
        end
      end

      context 'passing the full_name' do
        it 'returns user with a given full_name' do
          get api_users_path, params: { full_name: last_user_created.full_name }

          expect(request.query_parameters).to include(:full_name)
          expect(response_body['users'].count).to eq 1
          expect(response_body['users'].first['full_name']).to eq(last_user_created.full_name)
        end
        
        it 'returns nil with non existed full_name' do
          get api_users_path, params: { full_name: 'Foo Name' }

          expect(request.query_parameters).to include(:full_name)
          expect(response_body['users'].count).to eq 0
        end

        it 'returns users with the same full_name sorted by creation date (most recent first)' do
          first_user_created.full_name = last_user_created.full_name
          first_user_created.save

          get api_users_path, params: { full_name: last_user_created.full_name }

          expect(request.query_parameters).to include(:full_name)
          expect(response_body['users'].count).to eq 2
          expect(response_body['users'].first['full_name']).to eq(last_user_created.full_name)
          expect(response_body['users'].last['full_name']).to eq(first_user_created.full_name)
        end
      end

      context 'passing the metadata' do
        it 'returns user with a given metadata' do
          get api_users_path, params: { metadata: last_user_created.metadata }

          expect(request.query_parameters).to include(:metadata)
          expect(response_body['users'].count).to eq 1
          expect(response_body['users'].first['full_name']).to eq(last_user_created.full_name)
        end
        
        it 'returns nil with non existed full_name' do
          get api_users_path, params: { metadata: 'Foo metadata' }

          expect(request.query_parameters).to include(:metadata)
          expect(response_body['users'].count).to eq 0
        end
      end

      context 'passing multiple query params' do
        it 'returns user with granular search' do
          get api_users_path, params: {
            email: last_user_created.email,
            full_name: last_user_created.full_name,
            metadata: last_user_created.metadata
          }

          expect(request.query_parameters).to include(:email, :full_name, :metadata)
          expect(response_body['users'].count).to eq 1
          expect(response_body['users'].first['full_name']).to eq(last_user_created.full_name)
        end
      end

      context 'passing unpermitted query params' do
        before { get api_users_path, params: { unpermitted_param: 'foo' } }

        it "responds with an 'errors' object" do
          expect(response_body.keys).to eq ['errors']
        end

        it 'responds with an error message' do
          expect(response_body['errors'].first).to eq "found unpermitted parameter: :unpermitted_param"
        end
      end
    end
  end

  describe 'POST /api/users' do
    let(:valid_user_params) do
      {
        email: 'fooemail@gmail.com',
        phone_number: '9999999999',
        full_name: 'Foo name',
        password: 'foopass',
        metadata: 'male, age 32, unemployed, college-educated'
      }
    end

    context 'with valid params' do
      before { post api_users_path, params: { user: valid_user_params } }
  
      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'responds with a single user object' do
        expect(response_body).to be_a Hash
        expect(response_body['email']).to eq valid_user_params[:email]
        expect(response_body['phone_number']).to eq valid_user_params[:phone_number]
        expect(response_body['full_name']).to eq valid_user_params[:full_name]
        expect(response_body['key']).to be_a String
        expect(response_body['account_key']).to be_a String
        expect(response_body['metadata']).to eq valid_user_params[:metadata]
      end
    end

    context 'with invalid params' do
      before { post api_users_path, params: { user: invalid_user_params } }

      let(:invalid_user_params) do
        {
          email: 'fooemail',
          phone_number: '',
          full_name: 'Foo name',
          password: '',
          metadata: "male, age 32, unemployed, college-educated"
        }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end
      
      it 'responds with an array of errors' do
        expect(response_body['errors']).to match_array(
          ["Email is invalid", "Password can't be blank", "Phone number can't be blank"]
        )
      end

      context 'passing non-unique params' do
        before do
          2.times do |_| 
            post api_users_path, params: { user: valid_user_params }
          end
        end

        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
        
        it 'responds with an array of errors' do
          expect(response_body['errors']).to match_array(
            ["Email has already been taken", "Phone number has already been taken"]
          )
        end
      end

      context 'passing unpermitted params' do
        let(:with_unpermitted_params) do
          invalid_user_params.merge(key: 'randomkey', cellphone: '9999999999')
        end

        before { post api_users_path, params: { user: with_unpermitted_params } }
  
        it 'returns status code 422' do
          expect(response).to have_http_status(422)
        end
        
        it 'responds with an array of errors' do
          expect(response_body['errors']).to match_array(
            ["found unpermitted parameters: :key, :cellphone"]
          )
        end
      end
    end
  end

  private

    def response_body
      JSON.parse(response.body)
    end
end