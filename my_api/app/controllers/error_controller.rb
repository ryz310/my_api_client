# frozen_string_literal: true

# Error endpoint that returns deterministic JSON error payloads.
class ErrorController < ApplicationController
  def show
    render status: :bad_request, json: error_response
  end

  private

  def error_response
    code = params[:code].to_i
    {
      error: {
        code:,
        message: "You requested error code: #{code}",
      },
    }
  end
end
