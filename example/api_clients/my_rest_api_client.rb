# frozen_string_literal: true

require_relative 'application_api_client'

# An usage example of the `my_api_client`.
# See also: my_api/app/controllers/rest_controller.rb
class MyRestApiClient < ApplicationApiClient
  # GET rest
  def get_posts(order: :asc)
    order = :desc unless order == :asc
    query = { order: order }
    get 'rest', query: query, headers: headers
  end

  # GET rest/:id
  def get_post(id:)
    get "rest/#{id}", headers: headers
  end

  # POST rest
  def create_post(title:)
    body = { title: title }
    post 'rest', body: body, headers: headers
  end

  # POST/PUT/PATCH rest/:id
  def update_post(id:, title:)
    body = { title: title }
    patch "rest/#{id}", body: body, headers: headers
  end

  # DELETE rest/:id
  def delete_post(id:)
    delete "rest/#{id}", headers: headers
  end

  private

  def headers
    { 'Content-Type': 'application/json;charset=UTF-8' }
  end
end
