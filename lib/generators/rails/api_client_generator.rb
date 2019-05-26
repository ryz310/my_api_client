# frozen_string_literal: true

module Rails
  # rails g api_client
  class ApiClientGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('templates', __dir__)
    check_class_collision suffix: 'ApiClient'

    argument :endpoint,
             type: :string,
             default: 'https://example.com',
             banner: '{schema and hostname}'
    argument :requests,
             type: :array,
             default: %w[get_resource:get:path/to/resource post_resource:post:path/to/resource],
             banner: '{action}:{method}:{path} {action}:{method}:{path}'

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
