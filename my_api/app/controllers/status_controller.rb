# frozen_string_literal: true

# THe status API
class StatusController < ApplicationController
  # GET status/:status
  def show
    status = params[:status].to_i
    render status:,
           json: { message: "You requested status code: #{status}" }
  end
end
