# frozen_string_literal: true

RSpec.describe MyApiClient::Exceptions do
  let(:mock_class) do
    stub_const 'RetriableError', Class.new(StandardError)
    stub_const 'DiscardableError', Class.new(StandardError)

    Class.new do
      include MyApiClient::Exceptions

      retry_on Net::OpenTimeout, wait: 0.seconds, attempts: 1 do
        puts 'Retried but some network error occurred again.'
      end

      retry_on RetriableError, wait: 0.seconds, attempts: 2

      discard_on DiscardableError do
        puts 'A discardable error has occurred.'
      end

      def run
        call(:execute, 1, 2, 3)
      end

      private

      def execute(_first, _second, _third)
        'Success'
      end
    end
  end

  let(:instance) { mock_class.new }

  describe '#call' do
    subject(:execute_call) { instance.call(:execute, 1, 2, 3) }

    context 'when no error occurred' do
      before do
        allow(instance).to receive(:execute).and_call_original
      end

      it 'calls the method specified by the 1st argument' do
        execute_call
        expect(instance).to have_received(:execute).with(1, 2, 3)
      end

      it 'returns the result of execution' do
        expect(execute_call).to eq 'Success'
      end
    end

    context 'when an error occurs and succeeds due to retry' do
      before do
        results = [:raise, nil]
        allow(instance).to receive(:execute).twice do
          result = results.shift
          result == :raise ? raise(RetriableError) : 'Success'
        end
      end

      it 'calls the method specified by the 1st argument twice' do
        execute_call
        expect(instance).to have_received(:execute).with(1, 2, 3).twice
      end

      it 'returns the result of the retry' do
        expect(execute_call).to eq 'Success'
      end
    end

    context 'when an error occurs and fails again due to retry' do
      before do
        allow(instance).to receive(:execute).and_raise(RetriableError)
      end

      it 'returns the result of the retry' do
        expect { execute_call }.to raise_error(RetriableError)
      end
    end
  end

  describe '.retry_on' do
    context 'with &block' do
      context 'when it retries and solves' do
        before do
          results = [:raise, nil]
          allow(instance).to receive(:execute).twice do
            result = results.shift
            result == :raise ? raise(Net::OpenTimeout) : 'Success'
          end
        end

        it 'retries the method until succeeds and does not execute the block' do
          expect { instance.run }.not_to output.to_stdout
          expect(instance).to have_received(:execute).with(1, 2, 3).twice
        end
      end

      context 'when it retries and not solved' do
        before { allow(instance).to receive(:execute).and_raise(Net::OpenTimeout) }

        it 'retries the method and executes block at last' do
          expect { instance.run }
            .to output("Retried but some network error occurred again.\n").to_stdout
          expect(instance).to have_received(:execute).with(1, 2, 3).twice
        end
      end
    end

    context 'without &block' do
      context 'when it retries and solves' do
        before do
          results = [:raise, nil]
          allow(instance).to receive(:execute).twice do
            result = results.shift
            result == :raise ? raise(RetriableError) : 'Success'
          end
        end

        it 'retries the method until succeeds and does not raise the error' do
          expect { instance.run }.not_to raise_error
          expect(instance).to have_received(:execute).with(1, 2, 3).twice
        end
      end

      context 'when it retries and not solved' do
        before { allow(instance).to receive(:execute).and_raise(RetriableError) }

        it 'retries the method and raises the error at last' do
          expect { instance.run }.to raise_error(RetriableError)
          expect(instance).to have_received(:execute).with(1, 2, 3).exactly(3).times
        end
      end
    end
  end

  describe '.discard_on' do
    before { allow(instance).to receive(:execute).and_raise(DiscardableError) }

    it 'discards the error and executes the block' do
      expect { instance.run }.to output("A discardable error has occurred.\n").to_stdout
      expect(instance).to have_received(:execute).with(1, 2, 3).once
    end
  end
end
