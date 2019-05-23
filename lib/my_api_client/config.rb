# frozen_string_literal: true

module MyApiClient
  module Config
    extend ActiveSupport::Concern

    class_methods do
      %i[endpoint request_timeout net_open_timeout].each do |config_method|
        class_eval <<~METHOD, __FILE__, __LINE__ + 1
          def #{config_method}(#{config_method})
            define_method :#{config_method}, -> { #{config_method} }
          end
        METHOD
      end
    end
  end
end
