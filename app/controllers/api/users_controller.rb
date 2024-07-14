module Api
  class UsersController < ApplicationController
    def index
      users_ids = Rails.cache.fetch("all_users", expires_in: 5.seconds) do
        User.ids
      end
  
      @users = User.most_recently(users_ids)
      @users = @users.by_email(user_query_params[:email]) if user_query_params[:email].present?
      @users = @users.by_full_name(user_query_params[:full_name]) if user_query_params[:full_name].present?
      @users = @users.by_metadata(user_query_params[:metadata]) if user_query_params[:metadata].present?

      render json: { users: @users }
    rescue ActionController::UnpermittedParameters => e
      render json: { errors: [ e.message ] }, status: :unprocessable_entity
    end

    def create
      @user = User.new(user_params)

      if @user.save
        render json: @user, status: :created
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActionController::UnpermittedParameters => e
      render json: { errors: [ e.message ] }, status: :unprocessable_entity
    end

    private
  
      def user_query_params
        params.permit(:email, :full_name, :metadata)
      end

      def user_params
        params.require(:user).permit(:email, :phone_number, :full_name, :password, :metadata)
      end
  end
end
