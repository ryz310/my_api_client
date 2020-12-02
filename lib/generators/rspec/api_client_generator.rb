# frozen_string_literal: true

require 'generators/rspec'
require_relative '../generator_helper'

module Rspec
  module Generators
    # rails g rspec:api_client
    class ApiClientGenerator < Base
      include MyApiClient::GeneratorHelper

      source_root File.expand_path('templates', __dir__)

      argument :requests,
               type: :array,
               default: %w[get:path/to/resource post:path/to/resource],
               banner: '{method}:{path} {method}:{path}'

      class_option :endpoint,
                   type: :string,
                   default: 'https://example.com',
                   banner: 'https://example.com',
                   desc: 'Common part of the target API endpoint'

      class_option :api_client_specs, type: :boolean, default: true

      def generate_api_client_spec
        return unless options[:api_client_specs]

        file_path = File.join('spec/api_clients', "#{route_url.singularize}_api_client_spec.rb")
        template 'api_client_spec.rb.erb', file_path
      end
    end
  end
end
