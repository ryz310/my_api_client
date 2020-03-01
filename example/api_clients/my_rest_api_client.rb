# frozen_string_literal: true

require_relative 'application_api_client'

# An usage example of the `my_api_client`.
# See also: my_api/app/controllers/rest_controller.rb
class MyRestApiClient < ApplicationApiClient
  # GET rest
  def get_all_id
    get 'rest', headers: headers
  end

  # GET rest/:id
  def get_id(id:)
    get "rest/#{id}", headers: headers
  end

  # POST rest
  def post_id
    post 'rest', headers: headers
  end

  # POST/PUT/PATCH rest/:id
  def patch_id(id:)
    patch "rest/#{id}", headers: headers
  end

  # DELETE rest/:id
  def delete_id(id:)
    delete "rest/#{id}", headers: headers
  end

  private

  def headers
    { 'Content-Type': 'application/json;charset=UTF-8' }
  end
end
