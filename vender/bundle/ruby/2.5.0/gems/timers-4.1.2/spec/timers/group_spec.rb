# frozen_string_literal: true

RSpec.describe Timers::Group do
  describe "#wait" do
    it "calls the wait block with nil" do
      called = false

      subject.wait do |interval|
        expect(interval).to be_nil
        called = true
      end

      expect(called).to be true
    end

    it "calls the wait block with an interval" do
      called = false
      fired = false

      subject.after(0.1) { fired = true }

      subject.wait do |interval|
        expect(interval).to be_within(TIMER_QUANTUM).of(0.1)
        called = true
        sleep 0.2
      end

      expect(called).to be true
      expect(fired).to be true
    end
  end

  it "sleeps until the next timer" do
    interval   = TIMER_QUANTUM * 2
    started_at = Time.now

    fired = false
    subject.after(interval) { fired = true }
    subject.wait

    expect(fired).to be true
    expect(Time.now - started_at).to be_within(TIMER_QUANTUM).of interval
  end

  it "fires instantly when next timer is in the past" do
    fired = false
    subject.after(TIMER_QUANTUM) { fired = true }
    sleep(TIMER_QUANTUM * 2)
    subject.wait

    expect(fired).to be true
  end

  it "calculates the interval until the next timer should fire" do
    interval = 0.1

    subject.after(interval)
    expect(subject.wait_interval).to be_within(TIMER_QUANTUM).of interval

    sleep(interval)
    expect(subject.wait_interval).to be <= 0
  end

  it "fires timers in the correct order" do
    result = []

    subject.after(TIMER_QUANTUM * 2) { result << :two }
    subject.after(TIMER_QUANTUM * 3) { result << :three }
    subject.after(TIMER_QUANTUM * 1) { result << :one }

    sleep TIMER_QUANTUM * 4
    subject.fire

    expect(result).to eq [:one, :two, :three]
  end

  it "raises TypeError if given an invalid time" do
    expect do
      subject.after(nil) { nil }
    end.to raise_exception(TypeError)
  end

  describe "recurring timers" do
    it "continues to fire the timers at each interval" do
      result = []

      subject.every(TIMER_QUANTUM * 2) { result << :foo }

      sleep TIMER_QUANTUM * 3
      subject.fire
      expect(result).to eq [:foo]

      sleep TIMER_QUANTUM * 5
      subject.fire
      expect(result).to eq [:foo, :foo]
    end
  end

  it "calculates the proper interval to wait until firing" do
    interval_ms = 25

    subject.after(interval_ms / 1000.0)

    expect(subject.wait_interval).to be_within(TIMER_QUANTUM).of(interval_ms / 1000.0)
  end

  describe "pause and continue timers" do
    before(:each) do
      @interval = TIMER_QUANTUM * 2

      @fired = false
      @timer = subject.after(@interval) { @fired = true }
      @fired2 = false
      @timer2 = subject.after(@interval) { @fired2 = true }
    end

    it "does not fire when paused" do
      @timer.pause
      subject.wait
      expect(@fired).to be false
    end

    it "fires when continued after pause" do
      @timer.pause
      subject.wait
      @timer.resume

      sleep @timer.interval
      subject.wait

      expect(@fired).to be true
    end

    it "can pause all timers at once" do
      subject.pause
      subject.wait
      expect(@fired).to be false
      expect(@fired2).to be false
    end

    it "can continue all timers at once" do
      subject.pause
      subject.wait
      subject.resume

      # We need to wait until we are sure both timers will fire, otherwise highly accurate clocks
      # (e.g. JVM)may only fire the first timer, but not the second, because they are actually
      # schedueled at different times.
      sleep TIMER_QUANTUM * 2
      subject.wait

      expect(@fired).to be true
      expect(@fired2).to be true
    end

    it "can fire the timer directly" do
      fired = false
      timer = subject.after(TIMER_QUANTUM * 1) { fired = true }
      timer.pause
      subject.wait
      expect(fired).not_to be true
      timer.resume
      expect(fired).not_to be true
      timer.fire
      expect(fired).to be true
    end
  end

  describe "delay timer" do
    it "adds appropriate amount of time to timer" do
      timer = subject.after(10)
      timer.delay(5)
      expect(timer.offset - subject.current_offset).to be_within(TIMER_QUANTUM).of(15)
    end
  end

  describe "delay timer collection" do
    it "delay on set adds appropriate amount of time to all timers" do
      timer = subject.after(10)
      timer2 = subject.after(20)
      subject.delay(5)
      expect(timer.offset - subject.current_offset).to be_within(TIMER_QUANTUM).of(15)
      expect(timer2.offset - subject.current_offset).to be_within(TIMER_QUANTUM).of(25)
    end
  end

  describe "on delaying a timer" do
    it "fires timers in the correct order" do
      result = []

      subject.after(TIMER_QUANTUM * 2) { result << :two }
      subject.after(TIMER_QUANTUM * 3) { result << :three }
      first = subject.after(TIMER_QUANTUM * 1) { result << :one }
      first.delay(TIMER_QUANTUM * 3)

      sleep TIMER_QUANTUM * 5
      subject.fire

      expect(result).to eq [:two, :three, :one]
    end
  end

  describe "#inspect" do
    it "before firing" do
      fired = false
      timer = subject.after(TIMER_QUANTUM * 5) { fired = true }
      timer.pause
      expect(fired).not_to be true
      expect(timer.inspect).to match(/\A#<Timers::Timer:[\da-f]+ fires in [-\.\de]+ seconds>\Z/)
    end

    it "after firing" do
      fired = false
      timer = subject.after(TIMER_QUANTUM) { fired = true }

      subject.wait

      expect(fired).to be true
      expect(timer.inspect).to match(/\A#<Timers::Timer:[\da-f]+ fired [-\.\de]+ seconds ago>\Z/)
    end

    it "recurring firing" do
      result = []
      timer = subject.every(TIMER_QUANTUM) { result << :foo }

      subject.wait
      expect(result).not_to be_empty
      regex = /\A#<Timers::Timer:[\da-f]+ fires in [-\.\de]+ seconds, recurs every #{format("%0.2f", TIMER_QUANTUM)}>\Z/
      expect(timer.inspect).to match(regex)
    end
  end

  describe "#fires_in" do
    let(:interval) { TIMER_QUANTUM * 2 }

    it "calculates the interval until the next fire if it's recurring" do
      timer = subject.every(interval) { true }
      expect(timer.fires_in).to be_within(TIMER_QUANTUM).of(interval)
    end

    context "when timer is not recurring" do
      let!(:timer) { subject.after(interval) { true } }

      it "calculates the interval until the next fire if it hasn't already fired" do
        expect(timer.fires_in).to be_within(TIMER_QUANTUM).of(interval)
      end

      it "calculates the interval since last fire if already fired" do
        subject.wait
        sleep(interval)
        expect(timer.fires_in).to be_within(TIMER_QUANTUM).of(0 - interval)
      end
    end
  end
end
