# frozen_string_literal: true

# The header API
class HeaderController < ApplicationController
  # GET header
  def index
    params.each do |header_name, header_value|
      response.set_header(header_name, header_value)
    end
    render status: :ok, json: {}
  end
end
