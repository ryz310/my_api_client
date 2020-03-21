# frozen_string_literal: true

require 'openssl'
require 'net/http'
require 'logger'
require 'jsonpath'
require 'active_support'
require 'active_support/core_ext'
require 'sawyer'
require 'my_api_client/service_abstract'
require 'my_api_client/version'
require 'my_api_client/config'
require 'my_api_client/error_handling/generator'
require 'my_api_client/error_handling/retry_option_processor'
require 'my_api_client/error_handling'
require 'my_api_client/exceptions'
require 'my_api_client/request/logger'
require 'my_api_client/request/executor'
require 'my_api_client/request/basic'
require 'my_api_client/request/pagination'
require 'my_api_client/errors'
require 'my_api_client/params/params'
require 'my_api_client/params/request'
require 'my_api_client/request'
require 'my_api_client/base'
require 'my_api_client/sleeper'

# Loads gems for feature of integrations
begin
  require 'bugsnag'
  require 'my_api_client/integrations/bugsnag' if defined?(Bugsnag) && Bugsnag::VERSION >= '6.11.0'
rescue LoadError
  nil
end
