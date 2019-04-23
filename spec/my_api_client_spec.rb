# frozen_string_literal: true

RSpec.describe MyApiClient do
  it 'has a version number' do
    expect(MyApiClient::VERSION).not_to be_nil
  end
end
