# frozen_string_literal: true

RSpec.describe MyApiClient::Sleeper do
  describe '.call' do
    subject(:execute) { described_class.call(wait: wait) }

    context 'with `wait: 0.1.seconds`' do
      let(:wait) { 0.1.seconds }

      it 'sleeps about 0.1 seconds' do
        beginning_on = Time.now
        execute
        ending_on = Time.now
        expect(ending_on - beginning_on).to be_within(0.01.second).of(0.1.seconds)
      end
    end

    context 'with `wait: 0.2.seconds`' do
      let(:wait) { 0.2.seconds }

      it 'sleeps about 0.2 seconds' do
        beginning_on = Time.now
        execute
        ending_on = Time.now
        expect(ending_on - beginning_on).to be_within(0.01.second).of(0.2.seconds)
      end
    end
  end
end
