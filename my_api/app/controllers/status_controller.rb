# frozen_string_literal: true

class StatusController < ApplicationController
  def show
    status = params[:status].to_i
    render status:, json: { message: "You requested status code: #{status}" }
  end
end
