# frozen_string_literal: true

require_relative 'application_api_client'

# An usage example of the `my_api_client`.
# See also: my_api/app/controllers/header_controller.rb
class MyHeaderApiClient < ApplicationApiClient
  error_handling headers: { 'X-First-Header': /invalid/ },
                 raise: MyErrors::FirstHeaderIsInvalid

  error_handling headers: {
                   'X-First-Header': /unknown/,
                   'X-Second-Header': /error/,
                 },
                 raise: MyErrors::MultipleHeaderIsInvalid

  error_handling headers: { 'X-First-Header': /nothing/ },
                 status_code: 404,
                 raise: MyErrors::FirstHeaderHasNothingAndNotFound

  # GET header
  #
  # @param first_header [String] X-First-Header
  # @param second_header [String] X-Second-Header
  # @return [Sawyer::Resource]
  def get_header(first_header:, second_header:)
    get 'header', headers: headers, query: {
      'X-First-Header': first_header,
      'X-Second-Header': second_header,
    }.compact
  end

  private

  def headers
    { 'Content-Type': 'application/json;charset=UTF-8' }
  end
end
