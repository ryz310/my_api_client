# frozen_string_literal: true

require 'rspec/expectations'

RSpec::Matchers.define :complete_about do |expected_duration|
  attr_reader :actual_duration

  match do |processing|
    @actual_duration = stopwatch { processing.call }
    expect(actual_duration).to be_within(0.01.second).of(expected_duration)
  end

  chain(:second) {}
  chain(:seconds) {}

  failure_message do
    "expected to complete about #{expected_duration} seconds, but took #{actual_duration} seconds"
  end

  def stopwatch
    beginning_on = Time.now
    yield
    ending_on = Time.now
    ending_on - beginning_on
  end

  supports_block_expectations
end
