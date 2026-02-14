# frozen_string_literal: true

# Header endpoint used to test response header-based error handling.
class HeaderController < ApplicationController
  def index
    params.to_unsafe_h.each do |header_name, header_value|
      next unless header_name.start_with?('X-')

      response.set_header(header_name, header_value)
    end

    render status: :ok, json: {}
  end
end
