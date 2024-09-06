# frozen_string_literal: true

require_relative 'application_api_client'

# An usage example of the `my_api_client`.
# See also: my_api/app/controllers/status_controller.rb
class MyStatusApiClient < ApplicationApiClient
  error_handling status_code: 400, raise: MyErrors::BadRequest
  error_handling status_code: 401, raise: MyErrors::Unauthorized
  error_handling status_code: 403, raise: MyErrors::Forbidden

  # GET status/:status
  def get_status(status:)
    get "status/#{status}", headers:
  end

  private

  def headers
    { 'Content-Type': 'application/json;charset=UTF-8' }
  end
end
