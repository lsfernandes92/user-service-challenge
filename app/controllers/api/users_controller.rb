module Api
  class UsersController < ApplicationController
    def index
      @users = Rails.cache.fetch("all_users", expires_in: 1.day) do
        User.most_recently.load
      end
  
      render json: @users
    end
  end
end
