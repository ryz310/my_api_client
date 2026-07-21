# frozen_string_literal: true

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = ENV['CI'].present?
  config.consider_all_requests_local = true
  config.log_level = :warn
end
