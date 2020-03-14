# frozen_string_literal: true

# THe error code API
class ErrorController < ApplicationController
  # GET error/:code
  def show
    render status: :bad_request, json: error_response
  end

  private

  def error_response
    code = params[:code].to_i
    {
      error: {
        code: code,
        message: "You requested error code: #{code}",
      },
    }
  end
end
