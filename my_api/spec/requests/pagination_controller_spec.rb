# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaginationController do
  # GET /pagination
  it 'returns first page with next link' do
    get '/pagination', params: { page: 1 }

    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    expect(json.fetch('page')).to eq(1)
    expect(json.dig('links', 'next')).to end_with('/pagination?page=2')
  end

  # GET /pagination
  it 'returns not found for unsupported pages' do
    get '/pagination', params: { page: 4 }

    expect(response).to have_http_status(:not_found)
  end
end
