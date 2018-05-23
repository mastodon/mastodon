# frozen_string_literal: true

RSpec.shared_context "an NIO selectable" do
  let(:selector) { NIO::Selector.new }

  it "selects readable objects", retry: 5 do # retry: Flaky on OS X
    monitor = selector.register(readable_subject, :r)
    ready = selector.select(0)
    expect(ready).to be_an Enumerable
    expect(ready).to include monitor
  end

  it "does not select unreadable objects" do
    selector.register(unreadable_subject, :r)
    expect(selector.select(0)).to be_nil
  end

  it "selects writable objects" do
    monitor = selector.register(writable_subject, :w)
    ready = selector.select(0)
    expect(ready).to be_an Enumerable
    expect(ready).to include monitor
  end

  it "does not select unwritable objects" do
    selector.register(unwritable_subject, :w)
    expect(selector.select(0)).to be_nil
  end
end

RSpec.shared_context "an NIO selectable stream" do
  let(:selector) { NIO::Selector.new }
  let(:stream)   { pair.first }
  let(:peer)     { pair.last }

  it "selects readable when the other end closes" do
    monitor = selector.register(stream, :r)
    expect(selector.select(0)).to be_nil

    peer.close
    # Wait and give the TCP session time to close
    expect(selector.select(0.1)).to include monitor
  end
end

RSpec.shared_context "an NIO bidirectional stream" do
  let(:selector) { NIO::Selector.new }
  let(:stream)   { pair.first }
  let(:peer)     { pair.last }

  it "selects readable and writable", retry: 5 do # retry: Flaky on OS X
    selector.register(readable_subject, :rw)
    selector.select(0) do |m|
      expect(m.readiness).to eq(:rw)
    end
  end
  it "keeps readiness after the selectable has been closed" do
    selector.register(readable_subject, :rw)
    selector.select(0) do |m|
      expect(m.readiness).to eq(:rw)
      readable_subject.close
      expect(m.readiness).to eq(:rw)
    end
  end
end
