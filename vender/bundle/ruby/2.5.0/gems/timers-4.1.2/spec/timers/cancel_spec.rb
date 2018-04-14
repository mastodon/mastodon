# frozen_string_literal: true

RSpec.describe Timers::Group do
  it "should be able to cancel twice" do
    fired = false

    timer = subject.after(0.1) { fired = true }

    2.times do
      timer.cancel
      subject.wait
    end

    expect(fired).to be false
  end

  it "should be possble to reset after cancel" do
    fired = false

    timer = subject.after(0.1) { fired = true }
    timer.cancel

    subject.wait

    timer.reset

    subject.wait

    expect(fired).to be true
  end

  it "should cancel and remove one shot timers after they fire" do
    x = 0

    Timers::Wait.for(2) do |_remaining|
      timer = subject.every(0.2) { x += 1 }
      subject.after(0.1) { timer.cancel }

      subject.wait
    end

    expect(subject.timers).to be_empty
    expect(x).to be == 0
  end
end
