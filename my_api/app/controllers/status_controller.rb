# frozen_string_literal: true

# Status endpoint that echoes requested HTTP status code.
class StatusController < ApplicationController
  # GET /status/:status
  def show
    status = params[:status].to_i
    render status:, json: { message: "You requested status code: #{status}" }
  end
end
