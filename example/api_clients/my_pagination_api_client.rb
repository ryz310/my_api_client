# frozen_string_literal: true

require_relative 'application_api_client'

# An usage example of the `my_api_client`.
# See also: my_api/app/controllers/pagination_controller.rb
class MyPaginationApiClient < ApplicationApiClient
  # Paging with JSONPath
  # GET pagination?page=1
  def paging_with_jsonpath
    pget 'pagination', headers:, query: { page: 1 }, paging: '$.links.next'
  end

  # Paging with Proc
  # GET pagination?page=1
  def paging_with_proc
    pget 'pagination', headers:, query: { page: 1 }, paging: lambda { |response|
      response.data.links.next
    }
  end

  private

  def headers
    { 'Content-Type': 'application/json;charset=UTF-8' }
  end
end
