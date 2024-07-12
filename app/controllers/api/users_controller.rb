module Api
  class UsersController < ApplicationController
    def index
      users_ids = Rails.cache.fetch("all_users", expires_in: 5.seconds) do
        User.most_recently.ids
      end
  
      @users = User.where(id: users_ids)

      render json: { users: @users }
    end
  end
end
