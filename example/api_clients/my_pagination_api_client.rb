# frozen_string_literal: true

require_relative 'application_api_client'

# An usage example of the `my_api_client`.
# See also: my_api/app/controllers/pagination_controller.rb
class MyPaginationApiClient < ApplicationApiClient
  # GET pagination?page=1
  def pagination
    pget 'pagination', paging: '$.links.next', headers: headers
  end

  private

  def headers
    { 'Content-Type': 'application/json;charset=UTF-8' }
  end
end
