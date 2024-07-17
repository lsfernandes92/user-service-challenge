class ApplicationController < ActionController::API
  before_action :ensure_json_request

  def ensure_json_request
    if request.get?
      unless request.headers['Accept'] =~ /application\/json/
        render json: { errors: [ "The header 'Accept' must be defined or the type is not supported by the server" ] }, status: 406
      end
    end

    unless request.get?
      return if request.headers['Content-Type'] =~ /application\/json/
      render json: { errors: [ "The header 'Content-Type' must be defined or the type is not supported by the server" ] }, status: 415
    end
  end
end