require 'spec_helper'
require 'random_compat'

require 'stringio'
if defined?(Encoding)
  Encoding.default_external = 'ASCII-8BIT'
end

describe Buffer do
  r = Random.new
  random_seed = r.seed
  puts "buffer_io random seed: 0x#{random_seed.to_s(16)}"

  let :source do
    ''
  end

  def set_source(s)
    source.replace(s)
  end

  let :io do
    StringIO.new(source.dup)
  end

  let :buffer do
    Buffer.new(io)
  end

  it 'io returns internal io' do
    buffer.io.should == io
  end

  it 'close closes internal io' do
    expect(io).to receive(:close)
    buffer.close
  end

  it 'short feed and read all' do
    set_source 'aa'
    buffer.read.should == 'aa'
  end

  it 'short feed and read short' do
    set_source 'aa'
    buffer.read(1).should == 'a'
    buffer.read(1).should == 'a'
    buffer.read(1).should == nil
  end

  it 'long feed and read all' do
    set_source ' '*(1024*1024)
    s = buffer.read
    s.size.should == source.size
    s.should == source
  end

  it 'long feed and read mixed' do
    set_source ' '*(1024*1024)
    buffer.read(10).should == source.slice!(0, 10)
    buffer.read(10).should == source.slice!(0, 10)
    buffer.read(10).should == source.slice!(0, 10)
    s = buffer.read
    s.size.should == source.size
    s.should == source
  end

  it 'eof' do
    set_source ''
    buffer.read.should == ''
  end

  it 'eof 2' do
    set_source 'a'
    buffer.read.should == 'a'
    buffer.read.should == ''
  end

  it 'write short once and flush' do
    buffer.write('aa')
    buffer.flush
    io.string.should == 'aa'
  end

  it 'write short twice and flush' do
    buffer.write('a')
    buffer.write('a')
    buffer.flush
    io.string.should == 'aa'
  end

  it 'write long once and flush' do
    s = ' '*(1024*1024)
    buffer.write s
    buffer.flush
    io.string.size.should == s.size
    io.string.should == s
  end

  it 'write short multi and flush' do
    s = ' '*(1024*1024)
    1024.times {
      buffer.write ' '*1024
    }
    buffer.flush
    io.string.size.should == s.size
    io.string.should == s
  end

  it 'random read' do
    r = Random.new(random_seed)

    50.times {
      fragments = []

      r.rand(4).times do
        n = r.rand(1024*1400)
        s = r.bytes(n)
        fragments << s
      end

      io = StringIO.new(fragments.join)
      b = Buffer.new(io)

      fragments.each {|s|
        x = b.read(s.size)
        x.size.should == s.size
        x.should == s
      }
      b.empty?.should == true
      b.read.should == ''
    }
  end

  it 'random read_all' do
    r = Random.new(random_seed)

    50.times {
      fragments = []
      r.bytes(0)

      r.rand(4).times do
        n = r.rand(1024*1400)
        s = r.bytes(n)
        fragments << s
      end

      io = StringIO.new(fragments.join)
      b = Buffer.new(io)

      fragments.each {|s|
        x = b.read_all(s.size)
        x.size.should == s.size
        x.should == s
      }
      b.empty?.should == true
      lambda {
        b.read_all(1)
      }.should raise_error(EOFError)
    }
  end

  it 'random skip' do
    r = Random.new(random_seed)

    50.times {
      fragments = []

      r.rand(4).times do
        n = r.rand(1024*1400)
        s = r.bytes(n)
        fragments << s
      end

      io = StringIO.new(fragments.join)
      b = Buffer.new(io)

      fragments.each {|s|
        b.skip(s.size).should == s.size
      }
      b.empty?.should == true
      b.skip(1).should == 0
    }
  end

  it 'random skip_all' do
    r = Random.new(random_seed)

    50.times {
      fragments = []

      r.rand(4).times do
        n = r.rand(1024*1400)
        s = r.bytes(n)
        fragments << s
      end

      io = StringIO.new(fragments.join)
      b = Buffer.new(io)

      fragments.each {|s|
        lambda {
          b.skip_all(s.size)
        }.should_not raise_error
      }
      b.empty?.should == true
      lambda {
        b.skip_all(1)
      }.should raise_error(EOFError)
    }
  end

  it 'random write and flush' do
    r = Random.new(random_seed)

    50.times {
      s = r.bytes(0)
      io = StringIO.new
      b = Buffer.new(io)

      r.rand(4).times do
        n = r.rand(1024*1400)
        x = r.bytes(n)
        s << x
        b.write(x)
      end

      (io.string.size + b.size).should == s.size

      b.flush

      io.string.size.should == s.size
      io.string.should == s
    }
  end

  it 'random write and clear' do
    r = Random.new(random_seed)
    b = Buffer.new

    50.times {
      s = r.bytes(0)

      r.rand(4).times do
        n = r.rand(1024*1400)
        x = r.bytes(n)
        s << x
        b.write(x)
      end

      b.size.should == s.size
      b.clear
    }
  end
end
