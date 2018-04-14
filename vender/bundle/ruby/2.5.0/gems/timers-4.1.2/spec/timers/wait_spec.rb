# frozen_string_literal: true

require "spec_helper"
require "timers/wait"

RSpec.describe Timers::Wait do
  it "repeats until timeout expired" do
    timeout = Timers::Wait.new(5)
    count = 0

    timeout.while_time_remaining do |remaining|
      expect(remaining).to be_within(TIMER_QUANTUM).of(timeout.duration - count)

      count += 1
      sleep 1
    end

    expect(count).to eq(5)
  end

  it "yields results as soon as possible" do
    timeout = Timers::Wait.new(5)

    result = timeout.while_time_remaining do |_remaining|
      break :done
    end

    expect(result).to eq(:done)
  end
end
