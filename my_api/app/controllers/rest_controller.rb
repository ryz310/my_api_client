# frozen_string_literal: true

# A REST API
class RestController < ApplicationController
  # GET rest
  def index
    render json: [{ id: 1 }, { id: 2 }, { id: 3 }]
  end

  # GET rest/:id
  def show
    render json: { id: params[:id], message: 'The resource is readed.' }
  end

  # POST rest
  def create
    render json: { id: 1, message: 'The resource is created.' }
  end

  # POST/PUT/PATCH rest/:id
  def update
    render json: { id: params[:id], message: 'The resource is updated.' }
  end

  # DELETE rest/:id
  def delete
    render json: { id: params[:id], message: 'The resource is deleted.' }
  end
end
