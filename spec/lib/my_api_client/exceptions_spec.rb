# frozen_string_literal: true

RSpec.describe MyApiClient::Exceptions do
  class self::RetriableError < StandardError; end
  class self::DiscardableError < StandardError; end

  class self::SuperMockClass
    include MyApiClient::Exceptions

    retry_on_network_errors wait: 0.seconds, attempts: 1 do
      puts 'Retried but some network error occurred again.'
    end

    def run
      call(:execute, 1, 2, 3)
    end

    private

    def execute(_first, _second, _third); end
  end

  class self::MockClass < self::SuperMockClass
    retry_on RSpec::ExampleGroups::MyApiClientExceptions::RetriableError,
             wait: 0.seconds, attempts: 2

    discard_on RSpec::ExampleGroups::MyApiClientExceptions::DiscardableError do
      puts 'A discardable error has occurred.'
    end
  end

  let(:instance) { self.class::MockClass.new }

  describe '.retry_on_network_errors' do
    context 'when it retries and solves' do
      before do
        results = [:raise, true]
        allow(instance).to receive(:execute).twice do
          result = results.shift
          result == :raise ? raise(Net::OpenTimeout) : result
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

  describe '.retry_on' do
    context 'when it retries and solves' do
      before do
        results = [:raise, true]
        allow(instance).to receive(:execute).twice do
          result = results.shift
          result == :raise ? raise(self.class::RetriableError) : result
        end
      end

      it 'retries the method until succeeds and does not raise the error' do
        expect { instance.run }.not_to raise_error
        expect(instance).to have_received(:execute).with(1, 2, 3).twice
      end
    end

    context 'when it retries and not solved' do
      before { allow(instance).to receive(:execute).and_raise(self.class::RetriableError) }

      it 'retries the method and raises the error at last' do
        expect { instance.run }.to raise_error(self.class::RetriableError)
        expect(instance).to have_received(:execute).with(1, 2, 3).exactly(3).times
      end
    end
  end

  describe '.discard_on' do
    before { allow(instance).to receive(:execute).and_raise(self.class::DiscardableError) }

    it 'discards the error and executes the block' do
      expect { instance.run }.to output("A discardable error has occurred.\n").to_stdout
      expect(instance).to have_received(:execute).with(1, 2, 3).once
    end
  end
end
