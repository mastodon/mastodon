# frozen_string_literal: true

require "spec_helper"
require "timeout"

# Timeouts should be at least this precise (in seconds) to pass the tests
# Typical precision should be better than this, but if it's worse it will fail
# the tests
TIMEOUT_PRECISION = 0.1

# rubocop:disable Metrics/BlockLength
RSpec.describe NIO::Selector do
  let(:pair)   { IO.pipe }
  let(:reader) { pair.first }
  let(:writer) { pair.last }

  context ".backends" do
    it "knows all supported backends" do
      expect(described_class.backends).to be_a Array
      expect(described_class.backends.first).to be_a Symbol
    end
  end

  context "#initialize" do
    it "allows explicitly specifying a backend" do
      backend = described_class.backends.first
      selector = described_class.new(backend)
      expect(selector.backend).to eq backend
    end

    it "raises ArgumentError if given an invalid backend" do
      expect { described_class.new(:derp) }.to raise_error ArgumentError
    end

    it "raises TypeError if given a non-Symbol parameter" do
      expect { described_class.new(42).to raise_error TypeError }
    end
  end

  context "backend" do
    it "knows its backend" do
      expect(subject.backend).to be_a Symbol
    end
  end

  context "register" do
    it "registers IO objects" do
      monitor = subject.register(reader, :r)
      expect(monitor).not_to be_closed
    end

    it "raises TypeError if asked to register non-IO objects" do
      expect { subject.register(42, :r) }.to raise_exception TypeError
    end

    it "raises when asked to register after closing" do
      subject.close
      expect { subject.register(reader, :r) }.to raise_exception IOError
    end
  end

  it "knows which IO objects are registered" do
    subject.register(reader, :r)
    expect(subject).to be_registered(reader)
    expect(subject).not_to be_registered(writer)
  end

  it "deregisters IO objects" do
    subject.register(reader, :r)

    monitor = subject.deregister(reader)
    expect(subject).not_to be_registered(reader)
    expect(monitor).to be_closed
  end

  it "reports if it is empty" do
    expect(subject).to be_empty
    subject.register(reader, :r)
    expect(subject).not_to be_empty
  end

  # This spec might seem a bit silly, but this actually something the
  # Java NIO API specifically precludes that we need to work around
  it "allows reregistration of the same IO object across select calls" do
    monitor = subject.register(reader, :r)
    writer << "ohai"

    expect(subject.select).to include monitor
    expect(reader.read(4)).to eq("ohai")
    subject.deregister(reader)

    new_monitor = subject.register(reader, :r)
    writer << "thar"
    expect(subject.select).to include new_monitor
    expect(reader.read(4)).to eq("thar")
  end

  context "timeouts" do
    it "waits for a timeout when selecting" do
      monitor = subject.register(reader, :r)

      payload = "hi there"
      writer << payload

      timeout = 0.5
      started_at = Time.now
      expect(subject.select(timeout)).to include monitor
      expect(Time.now - started_at).to be_within(TIMEOUT_PRECISION).of(0)
      reader.read_nonblock(payload.size)

      started_at = Time.now
      expect(subject.select(timeout)).to be_nil
      expect(Time.now - started_at).to be_within(TIMEOUT_PRECISION).of(timeout)
    end

    it "raises ArgumentError if given a negative timeout" do
      subject.register(reader, :r)

      expect { subject.select(-1) }.to raise_exception(ArgumentError)
    end
  end

  context "wakeup" do
    it "wakes up if signaled to from another thread" do
      subject.register(reader, :r)

      thread = Thread.new do
        started_at = Time.now
        expect(subject.select).to eq []
        Time.now - started_at
      end

      timeout = 0.1
      sleep timeout
      subject.wakeup

      expect(thread.value).to be_within(TIMEOUT_PRECISION).of(timeout)
    end

    it "raises IOError if asked to wake up a closed selector" do
      subject.close
      expect(subject).to be_closed

      expect { subject.wakeup }.to raise_exception IOError
    end
  end

  context "select" do
    it "does not block on super small precision intervals" do
      wait_interval = 1e-4

      expect do
        Timeout.timeout(2) do
          subject.select(wait_interval)
        end
      end.not_to raise_error
    end

    it "selects IO objects" do
      writer << "ohai"
      unready = IO.pipe.first

      reader_monitor  = subject.register(reader, :r)
      unready_monitor = subject.register(unready, :r)

      selected = subject.select(0)
      expect(selected.size).to eq(1)
      expect(selected).to include reader_monitor
      expect(selected).not_to include unready_monitor
    end

    it "selects closed IO objects" do
      monitor = subject.register(reader, :r)
      expect(subject.select(0)).to be_nil

      thread = Thread.new { subject.select }
      Thread.pass while thread.status && thread.status != "sleep"

      writer.close
      selected = thread.value
      expect(selected).to include monitor
    end

    it "iterates across selected objects with a block" do
      readable1, writer = IO.pipe
      writer << "ohai"

      readable2, writer = IO.pipe
      writer << "ohai"

      unreadable = IO.pipe.first

      monitor1 = subject.register(readable1, :r)
      monitor2 = subject.register(readable2, :r)
      monitor3 = subject.register(unreadable, :r)

      readables = []
      result = subject.select { |monitor| readables << monitor }
      expect(result).to eq(2)

      expect(readables).to include monitor1
      expect(readables).to include monitor2
      expect(readables).not_to include monitor3
    end

    it "raises IOError if asked to select on a closed selector" do
      subject.close

      expect { subject.select(0) }.to raise_exception IOError
    end
  end

  it "closes" do
    subject.close
    expect(subject).to be_closed
  end
end
# rubocop:enable Metrics/BlockLength
