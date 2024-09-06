# frozen_string_literal: true

RSpec.describe MyApiClient::ErrorHandling do
  describe '.error_handling' do
    let(:parent_mock_class) do
      Class.new do
        include MyApiClient::ErrorHandling
        include MyApiClient::Exceptions

        class_attribute :error_handlers, default: []

        error_handling status_code: 400..499, raise: MyApiClient::ClientError
        error_handling status_code: 500..599, raise: MyApiClient::ServerError
      end
    end

    let(:child_mock_class) do
      Class.new(parent_mock_class) do
        error_handling status_code: 404, with: :not_found
        error_handling json: { '$.errors.code': 10 }, with: :error_code_10
        error_handling status_code: 200, json: :forbid_nil, with: :forbidden_from_being_blank
      end
    end

    let(:grand_child_mock_class) do
      Class.new(child_mock_class) do
        error_handling json: { '$.errors.code': 20 } do
          puts 'Use block'
        end
      end
    end

    let(:another_mock_class) do
      Class.new(parent_mock_class) do
        error_handling json: { '$.errors.code': 30 },
                       raise: MyApiClient::ApiLimitError,
                       retry_on: { wait: 1.minute }
      end
    end

    let(:instance) { instance_double(parent_mock_class) }
    let(:response) { instance_double(Sawyer::Response) }

    before do
      allow(MyApiClient::ErrorHandling::Generator).to receive(:call)
      allow(MyApiClient::ErrorHandling::RetryOptionProcessor).to receive(:call) do |options|
        options[:error_handling_options].delete(:retry_on)
      end
      allow(parent_mock_class).to receive(:retry_on)
    end

    shared_examples 'includes error handlers which defined parent class' do
      # rubocop:disable RSpec/ExampleLength
      it 'creates and adds error handlers to the list in a defined order' do
        target_mock_class.error_handlers[0].call(instance, response)
        expect(MyApiClient::ErrorHandling::Generator).to have_received(:call).with(
          status_code: 400..499,
          raise: MyApiClient::ClientError,
          instance:,
          response:,
          block: nil
        )
        target_mock_class.error_handlers[1].call(instance, response)
        expect(MyApiClient::ErrorHandling::Generator).to have_received(:call).with(
          status_code: 500..599,
          raise: MyApiClient::ServerError,
          instance:,
          response:,
          block: nil
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    shared_examples 'includes error handlers which defined child class' do
      # rubocop:disable RSpec/ExampleLength
      it 'creates and adds error handlers to the list in a defined order after the parent class' do
        target_mock_class.error_handlers[2].call(instance, response)
        expect(MyApiClient::ErrorHandling::Generator).to have_received(:call).with(
          status_code: 404,
          with: :not_found,
          instance:,
          response:,
          block: nil
        )
        target_mock_class.error_handlers[3].call(instance, response)
        expect(MyApiClient::ErrorHandling::Generator).to have_received(:call).with(
          json: { '$.errors.code': 10 },
          with: :error_code_10,
          instance:,
          response:,
          block: nil
        )
        target_mock_class.error_handlers[4].call(instance, response)
        expect(MyApiClient::ErrorHandling::Generator).to have_received(:call).with(
          status_code: 200,
          json: :forbid_nil,
          with: :forbidden_from_being_blank,
          instance:,
          response:,
          block: nil
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    shared_examples 'includes error handlers which defined grand child class' do
      it 'creates and adds error handlers to the list in a defined order after the child class' do
        target_mock_class.error_handlers[5].call(instance, response)
        expect(MyApiClient::ErrorHandling::Generator).to have_received(:call).with(
          json: { '$.errors.code': 20 },
          instance:,
          response:,
          block: instance_of(Proc)
        )
      end
    end

    shared_examples 'includes error handlers which defined another class' do
      it 'creates and adds error handlers, which is isolated from other child classes' do
        target_mock_class.error_handlers[2].call(instance, response)
        expect(MyApiClient::ErrorHandling::Generator).to have_received(:call).with(
          json: { '$.errors.code': 30 },
          raise: MyApiClient::ApiLimitError,
          instance:,
          response:,
          block: nil
        )
      end
    end

    shared_examples 'defines retry handling' do
      it 'defines retry handling because it includes a "retry_on" option' do
        target_mock_class
        expect(parent_mock_class).to have_received(:retry_on).with(
          MyApiClient::ApiLimitError, wait: 1.minute
        )
      end
    end

    shared_examples 'does not define retry handling' do
      it 'does not define retry handling because it does not include "retry_on" options' do
        target_mock_class
        expect(parent_mock_class).not_to have_received(:retry_on)
      end
    end

    describe 'Parent Class' do
      let(:target_mock_class) { parent_mock_class }

      it_behaves_like 'includes error handlers which defined parent class'
      it_behaves_like 'does not define retry handling'

      it 'is defined 2 error handlers' do
        expect(target_mock_class.error_handlers.count).to eq 2
      end
    end

    describe 'Child Class' do
      let(:target_mock_class) { child_mock_class }

      it_behaves_like 'includes error handlers which defined parent class'
      it_behaves_like 'includes error handlers which defined child class'
      it_behaves_like 'does not define retry handling'

      it 'is defined 5 error handlers' do
        expect(target_mock_class.error_handlers.count).to eq 5
      end
    end

    describe 'Grand Child Class' do
      let(:target_mock_class) { grand_child_mock_class }

      it_behaves_like 'includes error handlers which defined parent class'
      it_behaves_like 'includes error handlers which defined child class'
      it_behaves_like 'includes error handlers which defined grand child class'
      it_behaves_like 'does not define retry handling'

      it 'is defined 6 error handlers' do
        expect(target_mock_class.error_handlers.count).to eq 6
      end
    end

    describe 'Another Class' do
      let(:target_mock_class) { another_mock_class }

      it_behaves_like 'includes error handlers which defined parent class'
      it_behaves_like 'includes error handlers which defined another class'
      it_behaves_like 'defines retry handling'

      it 'is defined 3 error handlers' do
        expect(target_mock_class.error_handlers.count).to eq 3
      end
    end
  end
end
