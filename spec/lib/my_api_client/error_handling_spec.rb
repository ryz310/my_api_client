# frozen_string_literal: true

RSpec.describe MyApiClient::ErrorHandling do
  class self::SomeError < MyApiClient::Error; end

  class self::SuperMockClass
    include MyApiClient::ErrorHandling

    if ActiveSupport::VERSION::STRING >= '5.2.0'
      class_attribute :error_handlers, default: []
    else
      class_attribute :error_handlers
      self.error_handlers = []
    end

    # Commonized error handling
    error_handling status_code: 500, with: :commonized_error_handling
  end

  class self::MockClass < self::SuperMockClass
    # Use `status_code`
    error_handling status_code: /40[0-3]/, with: :status_code_is_monitored_by_regex
    error_handling status_code: 404, with: :status_code_is_monitored_by_number
    error_handling status_code: 405..499, with: :status_code_is_monitored_by_range

    # Use `json`
    error_handling json: { '$.errors.message': 'maintenance' }, with: :json_is_monitored_by_string
    error_handling json: { '$.errors.message': /[sS]orry/ }, with: :json_is_monitored_by_regex
    error_handling json: { '$.errors.code': 10 }, with: :json_is_monitored_by_number
    error_handling json: { '$.errors.code': 20..29 }, with: :json_is_monitored_by_range

    # Use complex patterns
    error_handling status_code: 200, json: { '$.errors.code': 30 },
                   with: :monitoring_with_status_code_and_json
    error_handling json: { '$.errors.code': 31, '$.errors.message': /[Uu]nknown/ },
                   with: :monitoring_with_json_multiple_conditions

    # Use `raise`
    error_handling json: { '$.errors.code': 40 },
                   raise: RSpec::ExampleGroups::MyApiClientErrorHandling::SomeError

    # Use `block`
    error_handling json: { '$.errors.code': 50 } do
      puts 'Error code 50 is detected'
    end

    # Default handling action
    error_handling json: { '$.errors.code': 60 }
  end

  class self::AnotherMockClass < self::SuperMockClass
    error_handling json: { '$.errors.code': 10 }
    error_handling json: { '$.errors.code': 20 }
    error_handling json: { '$.errors.code': 30 }
  end

  describe '.error_handling' do
    let(:instance) { self.class::MockClass.new }
    let(:error_handler) { instance.error_handling(response) }
    let(:response) do
      instance_double(
        Sawyer::Response, status: status_code, body: response_body.to_json
      )
    end
    let(:params) { instance_double(MyApiClient::Params::Params) }
    let(:logger) { instance_double(MyApiClient::Logger) }

    describe 'use `status_code`' do
      let(:response_body) { nil }

      describe 'with Regexp' do
        let(:status_code) { 401 }

        it 'monitors given status code with the regex pattern' do
          expect(error_handler).to eq :status_code_is_monitored_by_regex
        end
      end

      describe 'with Integer' do
        let(:status_code) { 404 }

        it 'monitors given status code with the number' do
          expect(error_handler).to eq :status_code_is_monitored_by_number
        end
      end

      describe 'with Range' do
        let(:status_code) { 408 }

        it 'monitors given status code within the range' do
          expect(error_handler).to eq :status_code_is_monitored_by_range
        end
      end
    end

    describe 'use `json`' do
      let(:status_code) { 200 }

      describe 'with String' do
        let(:response_body) do
          {
            errors: {
              message: 'maintenance',
            },
          }
        end

        it 'monitors given JSON with string' do
          expect(error_handler).to eq :json_is_monitored_by_string
        end
      end

      describe 'with Regexp' do
        let(:response_body) do
          {
            errors: {
              message: 'Sorry, something went wrong.',
            },
          }
        end

        it 'monitors given JSON with regex pattern' do
          expect(error_handler).to eq :json_is_monitored_by_regex
        end
      end

      describe 'with Integer' do
        let(:response_body) do
          {
            errors: {
              code: 10,
            },
          }
        end

        it 'monitors given JSON with number' do
          expect(error_handler).to eq :json_is_monitored_by_number
        end
      end

      describe 'with Range' do
        let(:response_body) do
          {
            errors: {
              code: 23,
            },
          }
        end

        it 'monitors given JSON within range' do
          expect(error_handler).to eq :json_is_monitored_by_range
        end
      end
    end

    describe 'use complex patterns' do
      describe 'status code and JSON' do
        let(:status_code) { 200 }
        let(:response_body) do
          {
            errors: {
              code: 30,
            },
          }
        end

        it 'monitors given status code and JSON' do
          expect(error_handler).to eq :monitoring_with_status_code_and_json
        end
      end

      describe 'JSON multiple conditions' do
        let(:status_code) { 200 }
        let(:response_body) do
          {
            errors: {
              code: 31,
              message: 'Unknown error',
            },
          }
        end

        it 'monitors given JSON for each path' do
          expect(error_handler).to eq :monitoring_with_json_multiple_conditions
        end
      end
    end

    describe 'use `raise`' do
      let(:status_code) { 200 }
      let(:response_body) do
        {
          errors: {
            code: 40,
          },
        }
      end

      it 'raises the error when detected' do
        expect { error_handler.call(params, logger) }.to raise_error(self.class::SomeError)
      end
    end

    describe 'use `block`' do
      let(:status_code) { 200 }
      let(:response_body) do
        {
          errors: {
            code: 50,
          },
        }
      end

      it 'executes the block when detected' do
        expect { error_handler.call(params, logger) }
          .to output("Error code 50 is detected\n")
          .to_stdout
      end
    end

    describe 'default handling action' do
      let(:status_code) { 200 }
      let(:response_body) do
        {
          errors: {
            code: 60,
          },
        }
      end

      it 'raises default error when detected' do
        expect { error_handler.call(params, logger) }.to raise_error(MyApiClient::Error)
      end
    end

    describe 'inheritance' do
      let(:status_code) { 500 }
      let(:response_body) { nil }

      it 'can be used super class error handlers' do
        expect(error_handler).to eq :commonized_error_handling
      end
    end

    describe 'definition' do
      it 'is isolate defined for each classes' do
        expect(self.class::SuperMockClass.error_handlers.count).to eq 1
        expect(self.class::MockClass.error_handlers.count).to eq 13
        expect(self.class::AnotherMockClass.error_handlers.count).to eq 4
      end
    end
  end

  class self::ParentMockClass
    include MyApiClient::ErrorHandling

    if ActiveSupport::VERSION::STRING >= '5.2.0'
      class_attribute :error_handlers, default: []
    else
      class_attribute :error_handlers
      self.error_handlers = []
    end

    error_handling status_code: 400,
                   with: :bad_request
  end

  class self::ChildMockClass < self::ParentMockClass
    error_handling status_code: 400,
                   json: { '$.errors.code': 10..19 },
                   with: :error_number_1x
    error_handling status_code: 400,
                   json: { '$.errors.code': 13 },
                   with: :error_number_13
  end

  class self::GrandchildMockClass < self::ChildMockClass
    error_handling status_code: 400,
                   json: { '$.errors.code': 13, '$.errors.message': 'error' },
                   with: :error_number_13_with_error_message
  end

  describe '#error_handling' do
    let(:instance) { self.class::GrandchildMockClass.new }
    let(:response_1) do
      instance_double(
        Sawyer::Response, status: 400, body: {
          errors: { code: 13, message: 'error' },
        }.to_json
      )
    end

    let(:response_2) do
      instance_double(
        Sawyer::Response, status: 400, body: {
          errors: { code: 13, message: 'warning' },
        }.to_json
      )
    end

    let(:response_3) do
      instance_double(
        Sawyer::Response, status: 400, body: {
          errors: { code: 15, message: 'error' },
        }.to_json
      )
    end

    let(:response_4) do
      instance_double(
        Sawyer::Response, status: 400, body: {
          errors: { code: 20, message: 'error' },
        }.to_json
      )
    end

    let(:response_5) do
      instance_double(Sawyer::Response, status: 200, body: nil)
    end

    it 'prioritizes error handlers which defined later' do
      expect(instance.error_handling(response_1)).to eq :error_number_13_with_error_message
      expect(instance.error_handling(response_2)).to eq :error_number_13
      expect(instance.error_handling(response_3)).to eq :error_number_1x
      expect(instance.error_handling(response_4)).to eq :bad_request
    end

    it 'returns nil when detected nothing' do
      expect(instance.error_handling(response_5)).to be_nil
    end
  end
end
