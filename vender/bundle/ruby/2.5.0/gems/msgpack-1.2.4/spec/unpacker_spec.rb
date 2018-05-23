# encoding: ascii-8bit

require 'stringio'
require 'tempfile'
require 'zlib'

require 'spec_helper'

describe MessagePack::Unpacker do
  let :unpacker do
    MessagePack::Unpacker.new
  end

  let :packer do
    MessagePack::Packer.new
  end

  it 'gets options to specify how to unpack values' do
    u1 = MessagePack::Unpacker.new
    u1.symbolize_keys?.should == false
    u1.allow_unknown_ext?.should == false

    u2 = MessagePack::Unpacker.new(symbolize_keys: true, allow_unknown_ext: true)
    u2.symbolize_keys?.should == true
    u2.allow_unknown_ext?.should == true
  end

  it 'gets IO or object which has #read to read data from it' do
    sample_data = {"message" => "morning!", "num" => 1}
    sample_packed = MessagePack.pack(sample_data).force_encoding('ASCII-8BIT')

    Tempfile.open("for_io") do |file|
      file.sync = true
      file.write sample_packed
      file.rewind

      u1 = MessagePack::Unpacker.new(file)
      u1.each do |obj|
        expect(obj).to eql(sample_data)
      end
      file.unlink
    end

    sio = StringIO.new(sample_packed)
    u2 = MessagePack::Unpacker.new(sio)
    u2.each do |obj|
      expect(obj).to eql(sample_data)
    end

    dio = StringIO.new
    Zlib::GzipWriter.wrap(dio){|gz| gz.write sample_packed }
    reader = Zlib::GzipReader.new(StringIO.new(dio.string))
    u3 = MessagePack::Unpacker.new(reader)
    u3.each do |obj|
      expect(obj).to eql(sample_data)
    end

    class DummyIO
      def initialize
        @buf = "".force_encoding('ASCII-8BIT')
        @pos = 0
      end
      def write(val)
        @buf << val.to_s
      end
      def read(length=nil,outbuf="")
        if @pos == @buf.size
          nil
        elsif length.nil?
          val = @buf[@pos..(@buf.size)]
          @pos = @buf.size
          outbuf << val
          outbuf
        else
          val = @buf[@pos..(@pos + length)]
          @pos += val.size
          @pos = @buf.size if @pos > @buf.size
          outbuf << val
          outbuf
        end
      end
      def flush
        # nop
      end
    end

    dio = DummyIO.new
    dio.write sample_packed
    u4 = MessagePack::Unpacker.new(dio)
    u4.each do |obj|
      expect(obj).to eql(sample_data)
    end
  end

  it 'read_array_header succeeds' do
    unpacker.feed("\x91")
    unpacker.read_array_header.should == 1
  end

  it 'read_array_header fails' do
    unpacker.feed("\x81")
    lambda {
      unpacker.read_array_header
    }.should raise_error(MessagePack::TypeError)  # TypeError is included in UnexpectedTypeError
    lambda {
      unpacker.read_array_header
    }.should raise_error(MessagePack::UnexpectedTypeError)
  end

  it 'read_map_header converts an map to key-value sequence' do
    packer.write_array_header(2)
    packer.write("e")
    packer.write(1)
    unpacker = MessagePack::Unpacker.new
    unpacker.feed(packer.to_s)
    unpacker.read_array_header.should == 2
    unpacker.read.should == "e"
    unpacker.read.should == 1
  end

  it 'read_map_header succeeds' do
    unpacker.feed("\x81")
    unpacker.read_map_header.should == 1
  end

  it 'read_map_header converts an map to key-value sequence' do
    packer.write_map_header(1)
    packer.write("k")
    packer.write("v")
    unpacker = MessagePack::Unpacker.new
    unpacker.feed(packer.to_s)
    unpacker.read_map_header.should == 1
    unpacker.read.should == "k"
    unpacker.read.should == "v"
  end

  it 'read_map_header fails' do
    unpacker.feed("\x91")
    lambda {
      unpacker.read_map_header
    }.should raise_error(MessagePack::TypeError)  # TypeError is included in UnexpectedTypeError
    lambda {
      unpacker.read_map_header
    }.should raise_error(MessagePack::UnexpectedTypeError)
  end

  it 'read raises EOFError before feeding' do
    lambda {
      unpacker.read
    }.should raise_error(EOFError)
  end

  let :sample_object do
    [1024, {["a","b"]=>["c","d"]}, ["e","f"], "d", 70000, 4.12, 1.5, 1.5, 1.5]
  end

  it 'feed and each continue internal state' do
    raw = sample_object.to_msgpack.to_s * 4
    objects = []

    raw.split(//).each do |b|
      unpacker.feed(b)
      unpacker.each {|c|
        objects << c
      }
    end

    objects.should == [sample_object] * 4
  end

  it 'feed_each continues internal state' do
    raw = sample_object.to_msgpack.to_s * 4
    objects = []

    raw.split(//).each do |b|
      unpacker.feed_each(b) {|c|
        objects << c
      }
    end

    objects.should == [sample_object] * 4
  end

  it 'feed_each enumerator' do
    raw = sample_object.to_msgpack.to_s * 4

    enum = unpacker.feed_each(raw)
    enum.should be_instance_of(Enumerator)
    enum.to_a.should == [sample_object] * 4
  end

  it 'reset clears internal buffer' do
    # 1-element array
    unpacker.feed("\x91")
    unpacker.reset
    unpacker.feed("\x01")

    unpacker.each.map {|x| x }.should == [1]
  end

  it 'reset clears internal state' do
    # 1-element array
    unpacker.feed("\x91")
    unpacker.each.map {|x| x }.should == []

    unpacker.reset

    unpacker.feed("\x01")
    unpacker.each.map {|x| x }.should == [1]
  end

  it 'frozen short strings' do
    raw = sample_object.to_msgpack.to_s.force_encoding('UTF-8')
    lambda {
      unpacker.feed_each(raw.freeze) { }
    }.should_not raise_error
  end

  it 'frozen long strings' do
    raw = (sample_object.to_msgpack.to_s * 10240).force_encoding('UTF-8')
    lambda {
      unpacker.feed_each(raw.freeze) { }
    }.should_not raise_error
  end

  it 'read raises invalid byte error' do
    unpacker.feed("\xc1")
    lambda {
      unpacker.read
    }.should raise_error(MessagePack::MalformedFormatError)
  end

  it "gc mark" do
    raw = sample_object.to_msgpack.to_s * 4

    n = 0
    raw.split(//).each do |b|
      GC.start
      unpacker.feed_each(b) {|o|
        GC.start
        o.should == sample_object
        n += 1
      }
      GC.start
    end

    n.should == 4
  end

  it "buffer" do
    orig = "a"*32*1024*4
    raw = orig.to_msgpack.to_s

    n = 655
    times = raw.size / n
    times += 1 unless raw.size % n == 0

    off = 0
    parsed = false

    times.times do
      parsed.should == false

      seg = raw[off, n]
      off += seg.length

      unpacker.feed_each(seg) {|obj|
        parsed.should == false
        obj.should == orig
        parsed = true
      }
    end

    parsed.should == true
  end

  it 'MessagePack.unpack symbolize_keys' do
    symbolized_hash = {:a => 'b', :c => 'd'}
    MessagePack.load(MessagePack.pack(symbolized_hash), :symbolize_keys => true).should == symbolized_hash
    MessagePack.unpack(MessagePack.pack(symbolized_hash), :symbolize_keys => true).should == symbolized_hash
  end

  it 'Unpacker#unpack symbolize_keys' do
    unpacker = MessagePack::Unpacker.new(:symbolize_keys => true)
    symbolized_hash = {:a => 'b', :c => 'd'}
    unpacker.feed(MessagePack.pack(symbolized_hash)).read.should == symbolized_hash
  end

  it "msgpack str 8 type" do
    MessagePack.unpack([0xd9, 0x00].pack('C*')).should == ""
    MessagePack.unpack([0xd9, 0x00].pack('C*')).encoding.should == Encoding::UTF_8
    MessagePack.unpack([0xd9, 0x01].pack('C*') + 'a').should == "a"
    MessagePack.unpack([0xd9, 0x02].pack('C*') + 'aa').should == "aa"
  end

  it "msgpack str 16 type" do
    MessagePack.unpack([0xda, 0x00, 0x00].pack('C*')).should == ""
    MessagePack.unpack([0xda, 0x00, 0x00].pack('C*')).encoding.should == Encoding::UTF_8
    MessagePack.unpack([0xda, 0x00, 0x01].pack('C*') + 'a').should == "a"
    MessagePack.unpack([0xda, 0x00, 0x02].pack('C*') + 'aa').should == "aa"
  end

  it "msgpack str 32 type" do
    MessagePack.unpack([0xdb, 0x00, 0x00, 0x00, 0x00].pack('C*')).should == ""
    MessagePack.unpack([0xdb, 0x00, 0x00, 0x00, 0x00].pack('C*')).encoding.should == Encoding::UTF_8
    MessagePack.unpack([0xdb, 0x00, 0x00, 0x00, 0x01].pack('C*') + 'a').should == "a"
    MessagePack.unpack([0xdb, 0x00, 0x00, 0x00, 0x02].pack('C*') + 'aa').should == "aa"
  end

  it "msgpack bin 8 type" do
    MessagePack.unpack([0xc4, 0x00].pack('C*')).should == ""
    MessagePack.unpack([0xc4, 0x00].pack('C*')).encoding.should == Encoding::ASCII_8BIT
    MessagePack.unpack([0xc4, 0x01].pack('C*') + 'a').should == "a"
    MessagePack.unpack([0xc4, 0x02].pack('C*') + 'aa').should == "aa"
  end

  it "msgpack bin 16 type" do
    MessagePack.unpack([0xc5, 0x00, 0x00].pack('C*')).should == ""
    MessagePack.unpack([0xc5, 0x00, 0x00].pack('C*')).encoding.should == Encoding::ASCII_8BIT
    MessagePack.unpack([0xc5, 0x00, 0x01].pack('C*') + 'a').should == "a"
    MessagePack.unpack([0xc5, 0x00, 0x02].pack('C*') + 'aa').should == "aa"
  end

  it "msgpack bin 32 type" do
    MessagePack.unpack([0xc6, 0x00, 0x00, 0x00, 0x00].pack('C*')).should == ""
    MessagePack.unpack([0xc6, 0x0, 0x00, 0x00, 0x000].pack('C*')).encoding.should == Encoding::ASCII_8BIT
    MessagePack.unpack([0xc6, 0x00, 0x00, 0x00, 0x01].pack('C*') + 'a').should == "a"
    MessagePack.unpack([0xc6, 0x00, 0x00, 0x00, 0x02].pack('C*') + 'aa').should == "aa"
  end

  describe "ext formats" do
    let(:unpacker) { MessagePack::Unpacker.new(allow_unknown_ext: true) }

    [1, 2, 4, 8, 16].zip([0xd4, 0xd5, 0xd6, 0xd7, 0xd8]).each do |n,b|
      it "msgpack fixext #{n} format" do
        unpacker.feed([b, 1].pack('CC') + "a"*n).unpack.should == MessagePack::ExtensionValue.new(1, "a"*n)
        unpacker.feed([b, -1].pack('CC') + "a"*n).unpack.should == MessagePack::ExtensionValue.new(-1, "a"*n)
      end
    end

    it "msgpack ext 8 format" do
      unpacker.feed([0xc7, 0, 1].pack('CCC')).unpack.should == MessagePack::ExtensionValue.new(1, "")
      unpacker.feed([0xc7, 255, -1].pack('CCC') + "a"*255).unpack.should == MessagePack::ExtensionValue.new(-1, "a"*255)
    end

    it "msgpack ext 16 format" do
      unpacker.feed([0xc8, 0, 1].pack('CnC')).unpack.should == MessagePack::ExtensionValue.new(1, "")
      unpacker.feed([0xc8, 256, -1].pack('CnC') + "a"*256).unpack.should == MessagePack::ExtensionValue.new(-1, "a"*256)
    end

    it "msgpack ext 32 format" do
      unpacker.feed([0xc9, 0, 1].pack('CNC')).unpack.should == MessagePack::ExtensionValue.new(1, "")
      unpacker.feed([0xc9, 256, -1].pack('CNC') + "a"*256).unpack.should == MessagePack::ExtensionValue.new(-1, "a"*256)
      unpacker.feed([0xc9, 65536, -1].pack('CNC') + "a"*65536).unpack.should == MessagePack::ExtensionValue.new(-1, "a"*65536)
    end
  end

  class ValueOne
    attr_reader :num
    def initialize(num)
      @num = num
    end
    def ==(obj)
      self.num == obj.num
    end
    def num
      @num
    end
    def to_msgpack_ext
      @num.to_msgpack
    end
    def self.from_msgpack_ext(data)
      self.new(MessagePack.unpack(data))
    end
  end

  class ValueTwo
    attr_reader :num_s
    def initialize(num)
      @num_s = num.to_s
    end
    def ==(obj)
      self.num_s == obj.num_s
    end
    def num
      @num_s.to_i
    end
    def to_msgpack_ext
      @num_s.to_msgpack
    end
    def self.from_msgpack_ext(data)
      self.new(MessagePack.unpack(data))
    end
  end

  describe '#type_registered?' do
    it 'receive Class or Integer, and return bool' do
      expect(subject.type_registered?(0x00)).to be_falsy
      expect(subject.type_registered?(0x01)).to be_falsy
      expect(subject.type_registered?(::ValueOne)).to be_falsy
    end

    it 'returns true if specified type or class is already registered' do
      subject.register_type(0x30, ::ValueOne, :from_msgpack_ext)
      subject.register_type(0x31, ::ValueTwo, :from_msgpack_ext)

      expect(subject.type_registered?(0x00)).to be_falsy
      expect(subject.type_registered?(0x01)).to be_falsy

      expect(subject.type_registered?(0x30)).to be_truthy
      expect(subject.type_registered?(0x31)).to be_truthy
      expect(subject.type_registered?(::ValueOne)).to be_truthy
      expect(subject.type_registered?(::ValueTwo)).to be_truthy
    end

    it 'cannot detect unpack rule with block, not method' do
      subject.register_type(0x40){|data| ValueOne.from_msgpack_ext(data) }

      expect(subject.type_registered?(0x40)).to be_truthy
      expect(subject.type_registered?(ValueOne)).to be_falsy
    end
  end

  context 'with ext definitions' do
    it 'get type and class mapping for packing' do
      unpacker = MessagePack::Unpacker.new
      unpacker.register_type(0x01){|data| ValueOne.from_msgpack_ext }
      unpacker.register_type(0x02){|data| ValueTwo.from_msgpack_ext(data) }

      unpacker = MessagePack::Unpacker.new
      unpacker.register_type(0x01, ValueOne, :from_msgpack_ext)
      unpacker.register_type(0x02, ValueTwo, :from_msgpack_ext)
    end

    it 'returns a Array of Hash which contains :type, :class and :unpacker' do
      unpacker = MessagePack::Unpacker.new
      unpacker.register_type(0x02, ValueTwo, :from_msgpack_ext)
      unpacker.register_type(0x01, ValueOne, :from_msgpack_ext)

      list = unpacker.registered_types

      expect(list).to be_a(Array)
      expect(list.size).to eq(2)

      one = list[0]
      expect(one.keys.sort).to eq([:type, :class, :unpacker].sort)
      expect(one[:type]).to eq(0x01)
      expect(one[:class]).to eq(ValueOne)
      expect(one[:unpacker]).to eq(:from_msgpack_ext)

      two = list[1]
      expect(two.keys.sort).to eq([:type, :class, :unpacker].sort)
      expect(two[:type]).to eq(0x02)
      expect(two[:class]).to eq(ValueTwo)
      expect(two[:unpacker]).to eq(:from_msgpack_ext)
    end

    it 'returns a Array of Hash, which contains nil for class if block unpacker specified' do
      unpacker = MessagePack::Unpacker.new
      unpacker.register_type(0x01){|data| ValueOne.from_msgpack_ext }
      unpacker.register_type(0x02, &ValueTwo.method(:from_msgpack_ext))

      list = unpacker.registered_types

      expect(list).to be_a(Array)
      expect(list.size).to eq(2)

      one = list[0]
      expect(one.keys.sort).to eq([:type, :class, :unpacker].sort)
      expect(one[:type]).to eq(0x01)
      expect(one[:class]).to be_nil
      expect(one[:unpacker]).to be_instance_of(Proc)

      two = list[1]
      expect(two.keys.sort).to eq([:type, :class, :unpacker].sort)
      expect(two[:type]).to eq(0x02)
      expect(two[:class]).to be_nil
      expect(two[:unpacker]).to be_instance_of(Proc)
    end

    describe "registering an ext type for a module" do
      subject { unpacker.feed("\xc7\x06\x00module").unpack }

      let(:unpacker) { MessagePack::Unpacker.new }

      before do
        mod = Module.new do
          def self.from_msgpack_ext(data)
            "unpacked #{data}"
          end
        end
        stub_const('Mod', mod)
      end

      before { unpacker.register_type(0x00, Mod, :from_msgpack_ext) }
      it { is_expected.to eq "unpacked module" }
    end
  end

  def flatten(struct, results = [])
    case struct
    when Array
      struct.each { |v| flatten(v, results) }
    when Hash
      struct.each { |k, v| flatten(v, flatten(k, results)) }
    else
      results << struct
    end
    results
  end

  subject do
    described_class.new
  end

  let :buffer1 do
    MessagePack.pack(:foo => 'bar')
  end

  let :buffer2 do
    MessagePack.pack(:hello => {:world => [1, 2, 3]})
  end

  let :buffer3 do
    MessagePack.pack(:x => 'y')
  end

  describe '#read' do
    context 'with a buffer' do
      it 'reads objects' do
        objects = []
        subject.feed(buffer1)
        subject.feed(buffer2)
        subject.feed(buffer3)
        objects << subject.read
        objects << subject.read
        objects << subject.read
        objects.should == [{'foo' => 'bar'}, {'hello' => {'world' => [1, 2, 3]}}, {'x' => 'y'}]
      end

      it 'reads map header' do
        subject.feed({}.to_msgpack)
        subject.read_map_header.should == 0
      end

      it 'reads array header' do
        subject.feed([].to_msgpack)
        subject.read_array_header.should == 0
      end
    end
  end

  describe '#each' do
    context 'with a buffer' do
      it 'yields each object in the buffer' do
        objects = []
        subject.feed(buffer1)
        subject.feed(buffer2)
        subject.feed(buffer3)
        subject.each do |obj|
          objects << obj
        end
        objects.should == [{'foo' => 'bar'}, {'hello' => {'world' => [1, 2, 3]}}, {'x' => 'y'}]
      end

      it 'returns an enumerator when no block is given' do
        subject.feed(buffer1)
        subject.feed(buffer2)
        subject.feed(buffer3)
        enum = subject.each
        enum.map { |obj| obj.keys.first }.should == %w[foo hello x]
      end
    end

    context 'with a stream passed to the constructor' do
      it 'yields each object in the stream' do
        objects = []
        unpacker = described_class.new(StringIO.new(buffer1 + buffer2 + buffer3))
        unpacker.each do |obj|
          objects << obj
        end
        objects.should == [{'foo' => 'bar'}, {'hello' => {'world' => [1, 2, 3]}}, {'x' => 'y'}]
      end
    end

    context 'with a stream and symbolize_keys passed to the constructor' do
      it 'yields each object in the stream, with symbolized keys' do
        objects = []
        unpacker = described_class.new(StringIO.new(buffer1 + buffer2 + buffer3), symbolize_keys: true)
        unpacker.each do |obj|
          objects << obj
        end
        objects.should == [{:foo => 'bar'}, {:hello => {:world => [1, 2, 3]}}, {:x => 'y'}]
      end
    end
  end

  describe '#feed_each' do
    it 'feeds the buffer then runs #each' do
      objects = []
      subject.feed_each(buffer1 + buffer2 + buffer3) do |obj|
        objects << obj
      end
      objects.should == [{'foo' => 'bar'}, {'hello' => {'world' => [1, 2, 3]}}, {'x' => 'y'}]
    end

    it 'handles chunked data' do
      objects = []
      buffer = buffer1 + buffer2 + buffer3
      buffer.chars.each do |ch|
        subject.feed_each(ch) do |obj|
          objects << obj
        end
      end
      objects.should == [{'foo' => 'bar'}, {'hello' => {'world' => [1, 2, 3]}}, {'x' => 'y'}]
    end
  end

  context 'regressions' do
    it 'handles massive arrays (issue #2)' do
      array = ['foo'] * 10_000
      MessagePack.unpack(MessagePack.pack(array)).size.should == 10_000
    end
  end

  context 'extensions' do
    context 'symbolized keys' do
      let :buffer do
        MessagePack.pack({'hello' => 'world', 'nested' => ['object', {'structure' => true}]})
      end

      let :unpacker do
        described_class.new(:symbolize_keys => true)
      end

      it 'can symbolize keys when using #each' do
        objs = []
        unpacker.feed(buffer)
        unpacker.each do |obj|
          objs << obj
        end
        objs.should == [{:hello => 'world', :nested => ['object', {:structure => true}]}]
      end

      it 'can symbolize keys when using #feed_each' do
        objs = []
        unpacker.feed_each(buffer) do |obj|
          objs << obj
        end
        objs.should == [{:hello => 'world', :nested => ['object', {:structure => true}]}]
      end
    end

    context 'binary encoding', :encodings do
      let :buffer do
        MessagePack.pack({'hello' => 'world', 'nested' => ['object', {'structure' => true}]})
      end

      let :unpacker do
        described_class.new()
      end

      it 'decodes binary as ascii-8bit when using #feed' do
        objs = []
        unpacker.feed(buffer)
        unpacker.each do |obj|
          objs << obj
        end
        strings = flatten(objs).grep(String)
        strings.should == %w[hello world nested object structure]
        strings.map(&:encoding).uniq.should == [Encoding::ASCII_8BIT]
      end

      it 'decodes binary as ascii-8bit when using #feed_each' do
        objs = []
        unpacker.feed_each(buffer) do |obj|
          objs << obj
        end
        strings = flatten(objs).grep(String)
        strings.should == %w[hello world nested object structure]
        strings.map(&:encoding).uniq.should == [Encoding::ASCII_8BIT]
      end
    end

    context 'string encoding', :encodings do
      let :buffer do
        MessagePack.pack({'hello'.force_encoding(Encoding::UTF_8) => 'world'.force_encoding(Encoding::UTF_8), 'nested'.force_encoding(Encoding::UTF_8) => ['object'.force_encoding(Encoding::UTF_8), {'structure'.force_encoding(Encoding::UTF_8) => true}]})
      end

      let :unpacker do
        described_class.new()
      end

      it 'decodes string as utf-8 when using #feed' do
        objs = []
        unpacker.feed(buffer)
        unpacker.each do |obj|
          objs << obj
        end
        strings = flatten(objs).grep(String)
        strings.should == %w[hello world nested object structure]
        strings.map(&:encoding).uniq.should == [Encoding::UTF_8]
      end

      it 'decodes binary as ascii-8bit when using #feed_each' do
        objs = []
        unpacker.feed_each(buffer) do |obj|
          objs << obj
        end
        strings = flatten(objs).grep(String)
        strings.should == %w[hello world nested object structure]
        strings.map(&:encoding).uniq.should == [Encoding::UTF_8]
      end
    end
  end
end
