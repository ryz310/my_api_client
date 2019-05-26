# frozen_string_literal: true

require 'generators/rspec'

module Rspec
  module Generators
    # rails g rspec:api_client
    class ApiClientGenerator < Base
      source_root File.expand_path('templates', __dir__)

      argument :endpoint,
               type: :string,
               default: 'https://example.com',
               banner: '{schema and hostname}'
      argument :requests,
               type: :array,
               default: %w[get_resource:get:path/to/resource post_resource:post:path/to/resource],
               banner: '{action}:{method}:{path} {action}:{method}:{path}'

      class_option :api_client_specs, type: :boolean, default: true

      def generate_api_client_spec
        return unless options[:api_client_specs]

        file_path = File.join('spec/api_clients', "#{route_url.singularize}_api_client_spec.rb")
        template 'api_client_spec.rb.erb', file_path
      end
    end
  end
end
