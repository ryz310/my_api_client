# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorController do
  # GET /error/:code
  it 'returns bad request with error payload' do
    get '/error/10'

    expect(response).to have_http_status(:bad_request)
    expect(JSON.parse(response.body)).to eq(
      'error' => {
        'code' => 10,
        'message' => 'You requested error code: 10',
      }
    )
  end
end
