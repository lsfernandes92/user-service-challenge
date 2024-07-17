# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :ensure_json_request

  def ensure_json_request
    if request.get? && request.headers['Accept'] !~ %r{application/json}
      render json: { errors: ["The header 'Accept' must be defined or the type is not supported by the server"] },
             status: 406
    end

    return if request.get?
    return if request.headers['Content-Type'] =~ %r{application/json}

    render json: { errors: ["The header 'Content-Type' must be defined or the type is not supported by the server"] },
           status: 415
  end
end
