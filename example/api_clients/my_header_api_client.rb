# frozen_string_literal: true

require_relative 'application_api_client'

# An usage example of the `my_api_client`.
# See also: my_api/app/controllers/header_controller.rb
class MyHeaderApiClient < ApplicationApiClient
  error_handling headers: { 'X-First-Header': /invalid/ },
                 raise: MyErrors::FirstHeaderIsInvalid

  error_handling headers: { 'X-First-Header': :zero? },
                 raise: MyErrors::FirstHeaderIs00

  error_handling headers: { 'X-First-Header': 100..199 },
                 raise: MyErrors::FirstHeaderIs1xx

  error_handling headers: {
                   'X-First-Header': 200..299,
                   'X-Second-Header': 300..399,
                 },
                 raise: MyErrors::MultipleHeaderIsInvalid

    error_handling headers: { 'X-First-Header': 30 },
                  raise: MyErrors::FirstHeaderIs30

  error_handling headers: { 'X-First-Header': 30 },
                 status_code: 404,
                 raise: MyErrors::FirstHeaderIs30WithNotFound

  # GET header
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
