# frozen_string_literal: true

# A REST API
class RestController < ApplicationController
  # GET rest
  def index
    render status: :ok,
           json: [{ id: 1 }, { id: 2 }, { id: 3 }]
  end

  # GET rest/:id
  def show
    render status: :ok,
           json: { id: id, message: 'The resource is readed.' }
  end

  # POST rest
  def create
    render status: :created,
           json: { id: 1, message: 'The resource is created.' }
  end

  # POST/PUT/PATCH rest/:id
  def update
    render status: :ok,
           json: { id: id, message: 'The resource is updated.' }
  end

  # DELETE rest/:id
  def delete
    render status: :no_content
  end

  private

  def id
    params[:id].to_i
  end
end
