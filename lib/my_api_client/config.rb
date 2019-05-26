# frozen_string_literal: true

module MyApiClient
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
  end
end
