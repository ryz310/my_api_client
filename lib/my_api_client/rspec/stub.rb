# frozen_string_literal: true

module MyApiClient
  # Test helper module for RSpec
  module Stub
    def stub_api_client_all(klass, **actions_and_options)
      instance = stub_api_client(klass, actions_and_options)
      allow(klass).to receive(:new).and_return(instance)
      instance
    end

    def stub_api_client(klass, **actions_and_options)
      instance = instance_double(klass)
      actions_and_options.each { |action, options| stubbing(instance, action, options) }
      instance
    end

    # Provides stubbing feature for `MyApiClient`.
    #
    # @param klass [Class]
    #   Stubbing target class.
    # @param action [Symbol]
    #   Stubbing target method name.
    # @param response [Object, nil]
    #   Stubbed ApiClient will return parameters set by `response`.
    #   default: nil
    # @param raise [Class, MyApiClient::Error, nil]
    #   Stubbed ApiClient will raise exception set by `raise`.
    #   You can set either exception class or exception instance.
    #   default: nil
    # @return [InstanceDouble]
    #   Returns a spy object for the ApiClient.
    # rubocop:disable Metrics/AbcSize
    def my_api_client_stub(klass, action, response: nil, raise: nil)
      ActiveSupport::Deprecation.warn(<<~MSG)
        `my_api_client_stub` is deprecated. Please use `stub_api_client` or `stub_api_client_all`.
      MSG

      instance = instance_double(klass)
      allow(klass).to receive(:new).and_return(instance)
      if raise.present?
        allow(instance).to receive(action).and_raise(process_raise_option(raise))
      elsif block_given?
        allow(instance).to receive(action) { |*request| stub_as_sawyer(yield(*request)) }
      else
        allow(instance).to receive(action).and_return(stub_as_sawyer(response))
      end
      instance
    end
    # rubocop:enable Metrics/AbcSize

    private

    # rubocop:disable Metrics/AbcSize
    def stubbing(instance, action, options)
      case options
      when Proc
        allow(instance).to receive(action) { |*request| stub_as_sawyer(options.call(*request)) }
      when Hash
        if options[:raise].present?
          allow(instance).to receive(action).and_raise(process_raise_option(options[:raise]))
        elsif options[:response]
          allow(instance).to receive(action).and_return(stub_as_sawyer(options[:response]))
        else
          allow(instance).to receive(action).and_return(stub_as_sawyer(options))
        end
      else
        allow(instance).to receive(action).and_return(stub_as_sawyer(options))
      end
    end
    # rubocop:enable Metrics/AbcSize

    # Provides a shorthand for `raise` option.
    # `MyApiClient::Error` requires `MyApiClient::Params::Params` instance on
    # initialize, but it makes trubolesome. `MyApiClient::NetworkError` is more.
    # If given a error instance, it will return raw value without processing.
    #
    # @param exception [Clsas, MyApiClient::Error] Processing target.
    # @return [MyApiClient::Error] Processed exception.
    # @raise [RuntimeError] Unsupported error class was set.
    def process_raise_option(exception)
      case exception
      when Class
        params = instance_double(MyApiClient::Params::Params, metadata: {})
        if exception == MyApiClient::NetworkError
          exception.new(params, Net::OpenTimeout.new)
        else
          exception.new(params)
        end
      when MyApiClient::Error
        exception
      else
        raise "Unsupported error class was set: #{exception.inspect}"
      end
    end

    def stub_as_sawyer(params)
      case params
      when Hash  then Sawyer::Resource.new(agent, params)
      when Array then params.map { |hash| stub_as_sawyer(hash) }
      when nil   then nil
      else params
      end
    end

    def agent
      instance_double('Sawyer::Agent').tap do |agent|
        allow(agent).to receive(:parse_links) do |data|
          data ||= {}
          links = data.delete(:_links)
          [data, links]
        end
      end
    end
  end
end
