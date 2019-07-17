# frozen_string_literal: true

require_relative '../generator_helper'

module Rails
  # rails g api_client
  class ApiClientGenerator < Rails::Generators::NamedBase
    include MyApiClient::GeneratorHelper

    source_root File.expand_path('templates', __dir__)
    check_class_collision suffix: 'ApiClient'

    argument :requests,
             type: :array,
             default: %w[get:path/to/resource post:path/to/resource],
             banner: '{method}:{path} {method}:{path}'

    def generate_root_class
      file_path = File.join('app/api_clients', 'application_api_client.rb')
      return if File.exist?(file_path)

      template 'application_api_client.rb.erb', file_path
    end

    def generate_api_client
      file_path = File.join('app/api_clients', "#{route_url.singularize}_api_client.rb")
      template 'api_client.rb.erb', file_path
    end

    hook_for :test_framework
  end
end
