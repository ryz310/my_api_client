# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RestController do
  # GET /rest
  it 'returns posts in ascending order by default' do
    get '/rest'

    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    expect(json.map { |post| post['id'] }).to eq([1, 2, 3])
  end

  # DELETE /rest/:id
  it 'returns null payload for delete endpoint' do
    delete '/rest/1'

    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to be_nil
  end
end
