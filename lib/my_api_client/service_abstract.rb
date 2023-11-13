# frozen_string_literal: true

module MyApiClient
  # The abstract class for service classes
  class ServiceAbstract
    private_class_method :new

    def self.call(...)
      new(...).send(:call)
    end

    # private

    # def initialize(**_args)
    #   raise "You must implement #{self.class}##{__method__}"
    # end

    # def call
    #   raise "You must implement #{self.class}##{__method__}"
    # end
  end
end
