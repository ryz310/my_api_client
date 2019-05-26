# frozen_string_literal: true

require 'dummy_app/api_clients/example_api_client'

class ExampleController
  def index
    users = api_client.read_users
    render status: :ok,
           json: { users: users.map { |user| { id: user.id, name: user.name } } }
  end

  def show
    user = api_client.read_user(params[:user_id])
    render status: :ok,
           json: { user: { id: user.id, name: user.name } }
  end

  def create
    user = api_client.create_user(params[:user_name])
    render status: :created,
           json: { user: { id: user.id, name: user.name } }
  end

  def update
    user = api_client.update_user(params[:user_id], params[:user_name])
    render status: :ok,
           json: { user: { id: user.id, name: user.name } }
  end

  def destroy
    api_client.delete_user(params[:user_id])
    render status: :ok
  end

  private

  def api_client
    @api_client ||= ExampleApiClient.new('access token')
  end
end
