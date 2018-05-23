# frozen_string_literal: true

RSpec.describe Timers::Events do
  it "should register an event" do
    fired = false

    callback = proc do |_time|
      fired = true
    end

    subject.schedule(0.1, callback)

    expect(subject.size).to be == 1

    subject.fire(0.15)

    expect(subject.size).to be == 0

    expect(fired).to be true
  end

  it "should register events in order" do
    fired = []

    times = [0.95, 0.1, 0.3, 0.5, 0.4, 0.2, 0.01, 0.9]

    times.each do |requested_time|
      callback = proc do |_time|
        fired << requested_time
      end

      subject.schedule(requested_time, callback)
    end

    subject.fire(0.5)
    expect(fired).to be == times.sort.first(6)

    subject.fire(1.0)
    expect(fired).to be == times.sort
  end

  it "should fire events with the time they were fired at" do
    fired_at = :not_fired

    callback = proc do |time|
      # The time we actually were fired at:
      fired_at = time
    end

    subject.schedule(0.5, callback)

    subject.fire(1.0)

    expect(fired_at).to be == 1.0
  end
end
