# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'action_controller/railtie'

Bundler.require(*Rails.groups)

module MyApi
  # Rails API application used for integration testing endpoints.
  class Application < Rails::Application
    config.load_defaults 8.1
    config.api_only = true
  end
end
