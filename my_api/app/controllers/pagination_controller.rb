# frozen_string_literal: true

# A Pagination API
class PaginationController < ApplicationController
  # GET pagination
  def index
    case params[:page]
    when '1', nil
      render status: :ok, json: first_page
    when '2'
      render status: :ok, json: second_page
    when '3'
      render status: :ok, json: third_page
    else
      render status: :not_found, json: ''
    end
  end

  private

  def first_page
    {
      links: {
        next: page_link(2),
      },
      page: 1,
    }
  end

  def second_page
    {
      links: {
        next: page_link(3),
        previous: page_link(1),
      },
      page: 2,
    }
  end

  def third_page
    {
      links: {
        previous: page_link(2),
      },
      page: 3,
    }
  end

  def page_link(page)
    query_strings = '?' + { page: page }.to_query
    URI.join(pagination_url, query_strings)
  end
end
