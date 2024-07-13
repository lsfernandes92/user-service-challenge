module Api
  class UsersController < ApplicationController
    def index
      users_ids = Rails.cache.fetch("all_users", expires_in: 5.seconds) do
        User.ids
      end
  
      @users = User.most_recently(users_ids)
      @users = @users.by_email(user_params[:email]) if user_params[:email].present?
      @users = @users.by_full_name(user_params[:full_name]) if user_params[:full_name].present?
      @users = @users.by_metadata(user_params[:metadata]) if user_params[:metadata].present?

      render json: { users: @users }
    rescue ActionController::UnpermittedParameters => e
      render json: { errors: [ e.message ] }, status: :unprocessable_entity
    end

    private
  
      def user_params
        params.permit(:email, :full_name, :metadata)
      end
  end
end
