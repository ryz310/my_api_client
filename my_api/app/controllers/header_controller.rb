# frozen_string_literal: true

class HeaderController < ApplicationController
  def index
    params.to_unsafe_h.each do |header_name, header_value|
      next unless header_name.start_with?('X-')

      response.set_header(header_name, header_value)
    end

    render status: :ok, json: {}
  end
end
