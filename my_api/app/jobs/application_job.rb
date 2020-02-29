# frozen_string_literal: true

# The root of the job class
class ApplicationJob < Jets::Job::Base
  # Adjust to increase the default timeout for all Job classes
  class_timeout 60
end
