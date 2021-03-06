# frozen_string_literal: true

module MyApiClient
  # Test helper module for RSpec
  module Stub
    ERROR_MESSAGE =
      'If you use the `raise` option as an error instance, the `response` option ' \
      'is ignored. If you want to use both options, you need to specify the ' \
      '`raise` option as an error class.'

    # Stubs all instance of arbitrary MyApiClient class.
    # And returns a stubbed arbitrary MyApiClient instance.
    #
    # @param klass [Class]
    #   Stubbing target class.
    # @param actions_and_options [Hash]
    #   Stubbing target method and options
    # @example
    #   stub_api_client_all(
    #     ExampleApiClient,
    #     get_users: {                                     # Returns an arbitrary pageable response
    #       pageable: [ { id: 1 }, { id: 2 }]              # for `#pageable_get`.
    #     },
    #     get_user: { response: { id: 1 } },               # Returns an arbitrary response.
    #     post_users: { id: 1 },                           # You can ommit `response` keyword.
    #     patch_user: ->(params) { { id: params[:id] } },  # Returns calculated result as response.
    #     put_user: { raise: MyApiClient::ClientError }    # Raises an arbitrary error.
    #     delete_user: {
    #       raise: MyApiClient::ClientError,
    #       response: { errors: [{ code: 10 }] },          # You can stub response with exception.
    #     }
    #   )
    #   response = ExampleApiClient.new.get_user(id: 123)
    #   response.id # => 1
    # @return [InstanceDouble]
    #   Returns a spy object of the stubbed ApiClient.
    def stub_api_client_all(klass, **actions_and_options)
      instance = stub_api_client(klass, **actions_and_options)
      allow(klass).to receive(:new).and_return(instance)
      instance
    end

    # Returns a stubbed arbitrary MyApiClient instance.
    #
    # @param klass [Class]
    #   Stubbing target class.
    # @param actions_and_options [Hash]
    #   Stubbing target method and options
    # @example
    #   api_client = stub_api_client(
    #     ExampleApiClient,
    #     get_users: {                                     # Returns an arbitrary pageable response
    #       pageable: [ { id: 1 }, { id: 2 }]              # for `#pageable_get`.
    #     },
    #     get_user: { response: { id: 1 } },               # Returns an arbitrary response.
    #     post_users: { id: 1 },                           # You can ommit `response` keyword.
    #     patch_user: ->(params) { { id: params[:id] } },  # Returns calculated result as response.
    #     put_user: { raise: MyApiClient::ClientError }    # Raises an arbitrary error.
    #     delete_user: {
    #       raise: MyApiClient::ClientError,
    #       response: { errors: [{ code: 10 }] },          # You can stub response with exception.
    #     }
    #   )
    #   response = api_client.get_user(id: 123)
    #   response.id # => 1
    # @return [InstanceDouble]
    #   Returns a spy object of the stubbed ApiClient.
    def stub_api_client(klass, **actions_and_options)
      instance = instance_double(klass)
      actions_and_options.each { |action, options| stubbing(instance, action, options) }
      instance
    end

    private

    def stubbing(instance, action, options)
      allow(instance).to receive(action) do |*request|
        generate_stubbed_response(options, *request)
      end
    end

    def generate_stubbed_response(options, *request)
      case options
      when Proc
        stub_as_resource(options.call(*request))
      when Hash
        if options[:raise].present?
          raise process_raise_option(options[:raise], options[:response])
        elsif options[:response].present?
          stub_as_resource(options[:response])
        elsif options[:pageable].present? && options[:pageable].is_a?(Enumerable)
          stub_as_pageable_resource(options[:pageable].each, *request)
        else
          stub_as_resource(options)
        end
      else
        stub_as_resource(options)
      end
    end

    def stub_as_pageable_resource(pager, *request)
      Enumerator.new do |y|
        loop do
          y << generate_stubbed_response(pager.next, *request)
        rescue StopIteration
          break
        end
      end.lazy
    end

    # Provides a shorthand for `raise` option.
    # `MyApiClient::Error` requires `MyApiClient::Params::Params` instance on
    # initialize, but it makes trubolesome. `MyApiClient::NetworkError` is more.
    # If given a error instance, it will return raw value without processing.
    #
    # @param exception [Clsas, MyApiClient::Error] Processing target.
    # @return [MyApiClient::Error] Processed exception.
    # @raise [RuntimeError] Unsupported error class was set.
    def process_raise_option(exception, response = {})
      case exception
      when Class
        params = MyApiClient::Params::Params.new(nil, stub_as_response(response))
        if exception == MyApiClient::NetworkError
          exception.new(params, Net::OpenTimeout.new)
        else
          exception.new(params)
        end
      when MyApiClient::Error
        raise ERROR_MESSAGE if response.present?

        exception
      else
        raise "Unsupported error class was set: #{exception.inspect}"
      end
    end

    def stub_as_response(params)
      instance_double(
        Sawyer::Response,
        status: 400,
        headers: {},
        data: stub_as_resource(params),
        timing: 0.123
      )
    end

    def stub_as_resource(params)
      case params
      when Hash  then Sawyer::Resource.new(agent, params)
      when Array then params.map { |hash| stub_as_resource(hash) }
      when nil   then nil
      else params
      end
    end

    def agent
      instance_double(Sawyer::Agent).tap do |agent|
        allow(agent).to receive(:parse_links) do |data|
          data ||= {}
          links = data.delete(:_links)
          [data, links]
        end
      end
    end
  end
end
