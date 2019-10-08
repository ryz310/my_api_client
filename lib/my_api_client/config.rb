# frozen_string_literal: true

module MyApiClient
  # Description of Config
  module Config
    extend ActiveSupport::Concern

    CONFIG_METHODS = %i[endpoint http_read_timeout http_open_timeout].freeze

    class_methods do
      CONFIG_METHODS.each do |config_method|
        class_eval <<~METHOD, __FILE__, __LINE__ + 1
          def #{config_method}(#{config_method})
            define_method :#{config_method}, -> { #{config_method} }
          end
        METHOD
      end
    end

    # Extracts schema and hostname from endpoint
    #
    # @example Extracts schema and hostname from 'https://example.com/path/to/api'
    #   schema_and_hostname # => 'https://example.com'
    # @return [String] description_of_returned_object
    def schema_and_hostname
      if _uri.default_port == _uri.port
        "#{_uri.scheme}://#{_uri.host}"
      else
        "#{_uri.scheme}://#{_uri.host}:#{_uri.port}"
      end
    end

    # Extracts pathname from endpoint
    #
    # @example Extracts pathname from 'https://example.com/path/to/api'
    #   common_path # => 'path/to/api'
    # @return [String] The pathanem
    def common_path
      _uri.path
    end

    private

    # @return [URI] Returns a memoized URI instance
    def _uri
      @_uri ||= URI.parse(endpoint)
    end
  end
end
