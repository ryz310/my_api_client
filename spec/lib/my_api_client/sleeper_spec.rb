# frozen_string_literal: true

RSpec.describe MyApiClient::Sleeper do
  describe '.call' do
    subject(:execute) { described_class.call(wait:) }

    shared_examples 'sleep processing' do |sleep_time|
      context "with `wait: #{sleep_time}`" do
        let(:wait) { sleep_time }

        it "sleeps about #{sleep_time} seconds" do
          expect { execute }.to complete_about(sleep_time).seconds
        end
      end
    end

    it_behaves_like 'sleep processing', 0.1.seconds
    it_behaves_like 'sleep processing', 0.2.seconds
    it_behaves_like 'sleep processing', 0.3.seconds
  end
end
