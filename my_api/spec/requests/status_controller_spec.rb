# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusController do
  # GET /status/:status
  it 'echoes requested status and message' do
    get '/status/200'

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to eq('message' => 'You requested status code: 200')
  end

  # GET /status/:status
  it 'returns requested non-200 status code' do
    get '/status/404'

    expect(response).to have_http_status(:not_found)
  end
end
