# frozen_string_literal: true

class RestController < ApplicationController
  def index
    result = params[:order] == 'desc' ? posts.reverse : posts
    render status: :ok, json: result
  end

  def show
    render status: :ok, json: find_post(id:)
  end

  def create
    render status: :created, json: create_post(title: params[:title])
  end

  def update
    render status: :ok, json: update_post(id:, title: params[:title])
  end

  def destroy
    head :no_content
  end

  private

  def id
    params[:id].to_i
  end

  def posts
    [
      { id: 1, title: 'Title 1' },
      { id: 2, title: 'Title 2' },
      { id: 3, title: 'Title 3' },
    ]
  end

  def find_post(id:)
    posts.find { |post| post[:id] == id }
  end

  def create_post(title:)
    { id: 4, title: }
  end

  def update_post(id:, title:)
    find_post(id:).tap { |post| post[:title] = title }
  end
end
