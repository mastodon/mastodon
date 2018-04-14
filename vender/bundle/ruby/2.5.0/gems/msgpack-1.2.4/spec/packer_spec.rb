# encoding: ascii-8bit
require 'spec_helper'

require 'stringio'
require 'tempfile'
require 'zlib'

if defined?(Encoding)
  Encoding.default_external = 'ASCII-8BIT'
end

describe MessagePack::Packer do
  let :packer do
    MessagePack::Packer.new
  end

  it 'initialize' do
    MessagePack::Packer.new
    MessagePack::Packer.new(nil)
    MessagePack::Packer.new(StringIO.new)
    MessagePack::Packer.new({})
    MessagePack::Packer.new(StringIO.new, {})
  end

  it 'gets IO or object which has #write to write/append data to it' do
    sample_data = {"message" => "morning!", "num" => 1}
    sample_packed = MessagePack.pack(sample_data)

    Tempfile.open("for_io") do |file|
      file.sync = true
      p1 = MessagePack::Packer.new(file)
      p1.write sample_data
      p1.flush

      file.rewind
      expect(file.read).to eql(sample_packed)
      file.unlink
    end

    dio = StringIO.new
    p2 = MessagePack::Packer.new(dio)
    p2.write sample_data
    p2.flush
    dio.rewind
    expect(dio.string).to eql(sample_packed)

    dio = StringIO.new
    writer = Zlib::GzipWriter.new(dio)
    writer.sync = true
    p3 = MessagePack::Packer.new(writer)
    p3.write sample_data
    p3.flush
    writer.flush(Zlib::FINISH)
    writer.close
    dio.rewind
    compressed = dio.string
    str = Zlib::GzipReader.wrap(StringIO.new(compressed)){|gz| gz.read }
    expect(str).to eql(sample_packed)

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
      def close
        # nop
      end
    end

    dio = DummyIO.new
    p4 = MessagePack::Packer.new(dio)
    p4.write sample_data
    p4.flush
    expect(dio.read).to eql(sample_packed)
  end

  it 'gets options to specify how to pack values' do
    u1 = MessagePack::Packer.new
    u1.compatibility_mode?.should == false

    u2 = MessagePack::Packer.new(compatibility_mode: true)
    u2.compatibility_mode?.should == true
  end

  it 'write' do
    packer.write([])
    packer.to_s.should == "\x90"
  end

  it 'write_nil' do
    packer.write_nil
    packer.to_s.should == "\xc0"
  end

  it 'write_array_header 0' do
    packer.write_array_header(0)
    packer.to_s.should == "\x90"
  end

  it 'write_array_header 1' do
    packer.write_array_header(1)
    packer.to_s.should == "\x91"
  end

  it 'write_map_header 0' do
    packer.write_map_header(0)
    packer.to_s.should == "\x80"
  end

  it 'write_map_header 1' do
    packer.write_map_header(1)
    packer.to_s.should == "\x81"
  end

  describe '#write_float32' do
    tests = [
      ['small floats', 3.14, "\xCA\x40\x48\xF5\xC3"],
      ['big floats', Math::PI * 1_000_000_000_000_000_000, "\xCA\x5E\x2E\x64\xB7"],
      ['negative floats', -2.1, "\xCA\xC0\x06\x66\x66"],
      ['integer', 123, "\xCA\x42\xF6\x00\x00"],
    ]

    tests.each do |ctx, numeric, packed|
      context("with #{ctx}") do
        it("encodes #{numeric} as float32") do
          packer.write_float32(numeric)
          packer.to_s.should == packed
        end
      end
    end

    context 'with non numeric' do
      it 'raises argument error' do
        expect { packer.write_float32('abc') }.to raise_error(ArgumentError)
      end
    end
  end

  it 'flush' do
    io = StringIO.new
    pk = MessagePack::Packer.new(io)
    pk.write_nil
    pk.flush
    pk.to_s.should == ''
    io.string.should == "\xc0"
  end

  it 'to_msgpack returns String' do
    nil.to_msgpack.class.should == String
    true.to_msgpack.class.should == String
    false.to_msgpack.class.should == String
    1.to_msgpack.class.should == String
    1.0.to_msgpack.class.should == String
    "".to_msgpack.class.should == String
    Hash.new.to_msgpack.class.should == String
    Array.new.to_msgpack.class.should == String
  end

  it 'to_msgpack with packer equals to_msgpack' do
    nil.to_msgpack(MessagePack::Packer.new).to_str.should == nil.to_msgpack
    true.to_msgpack(MessagePack::Packer.new).to_str.should == true.to_msgpack
    false.to_msgpack(MessagePack::Packer.new).to_str.should == false.to_msgpack
    1.to_msgpack(MessagePack::Packer.new).to_str.should == 1.to_msgpack
    1.0.to_msgpack(MessagePack::Packer.new).to_str.should == 1.0.to_msgpack
    "".to_msgpack(MessagePack::Packer.new).to_str.should == "".to_msgpack
    Hash.new.to_msgpack(MessagePack::Packer.new).to_str.should == Hash.new.to_msgpack
    Array.new.to_msgpack(MessagePack::Packer.new).to_str.should == Array.new.to_msgpack
  end

  it 'raises type error on wrong type' do
    packer = MessagePack::Packer.new
    expect { packer.write_float "hello" }.to raise_error(TypeError)
    expect { packer.write_string 1 }.to raise_error(TypeError)
    expect { packer.write_array "hello" }.to raise_error(TypeError)
    expect { packer.write_hash "hello" }.to raise_error(TypeError)
    expect { packer.write_symbol "hello" }.to raise_error(TypeError)
    expect { packer.write_int "hello" }.to raise_error(TypeError)
    expect { packer.write_extension "hello" }.to raise_error(TypeError)
  end

  class CustomPack01
    def to_msgpack(pk=nil)
      return MessagePack.pack(self, pk) unless pk.class == MessagePack::Packer
      pk.write_array_header(2)
      pk.write(1)
      pk.write(2)
      return pk
    end
  end

  class CustomPack02
    def to_msgpack(pk=nil)
      [1,2].to_msgpack(pk)
    end
  end

  it 'calls custom to_msgpack method' do
    MessagePack.pack(CustomPack01.new).should == [1,2].to_msgpack
    MessagePack.pack(CustomPack02.new).should == [1,2].to_msgpack
    CustomPack01.new.to_msgpack.should == [1,2].to_msgpack
    CustomPack02.new.to_msgpack.should == [1,2].to_msgpack
  end

  it 'calls custom to_msgpack method with io' do
    s01 = StringIO.new
    MessagePack.pack(CustomPack01.new, s01)
    s01.string.should == [1,2].to_msgpack

    s02 = StringIO.new
    MessagePack.pack(CustomPack02.new, s02)
    s02.string.should == [1,2].to_msgpack

    s03 = StringIO.new
    CustomPack01.new.to_msgpack(s03)
    s03.string.should == [1,2].to_msgpack

    s04 = StringIO.new
    CustomPack02.new.to_msgpack(s04)
    s04.string.should == [1,2].to_msgpack
  end

  context 'in compatibility mode' do
    it 'does not use the bin types' do
      packed = MessagePack.pack('hello'.force_encoding(Encoding::BINARY), compatibility_mode: true)
      packed.should eq("\xA5hello")
      packed = MessagePack.pack(('hello' * 100).force_encoding(Encoding::BINARY), compatibility_mode: true)
      packed.should start_with("\xDA\x01\xF4")

      packer = MessagePack::Packer.new(compatibility_mode: 1)
      packed = packer.pack(('hello' * 100).force_encoding(Encoding::BINARY))
      packed.to_str.should start_with("\xDA\x01\xF4")
    end

    it 'does not use the str8 type' do
      packed = MessagePack.pack('x' * 32, compatibility_mode: true)
      packed.should start_with("\xDA\x00\x20")
    end
  end

  class ValueOne
    def initialize(num)
      @num = num
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
    def initialize(num)
      @num_s = num.to_s
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
      subject.register_type(0x30, ::ValueOne, :to_msgpack_ext)
      subject.register_type(0x31, ::ValueTwo, :to_msgpack_ext)

      expect(subject.type_registered?(0x00)).to be_falsy
      expect(subject.type_registered?(0x01)).to be_falsy

      expect(subject.type_registered?(0x30)).to be_truthy
      expect(subject.type_registered?(0x31)).to be_truthy
      expect(subject.type_registered?(::ValueOne)).to be_truthy
      expect(subject.type_registered?(::ValueTwo)).to be_truthy
    end
  end

  describe '#register_type' do
    it 'get type and class mapping for packing' do
      packer = MessagePack::Packer.new
      packer.register_type(0x01, ValueOne){|obj| obj.to_msgpack_ext }
      packer.register_type(0x02, ValueTwo){|obj| obj.to_msgpack_ext }

      packer = MessagePack::Packer.new
      packer.register_type(0x01, ValueOne, :to_msgpack_ext)
      packer.register_type(0x02, ValueTwo, :to_msgpack_ext)

      packer = MessagePack::Packer.new
      packer.register_type(0x01, ValueOne, &:to_msgpack_ext)
      packer.register_type(0x02, ValueTwo, &:to_msgpack_ext)
    end

    it 'returns a Hash which contains map of Class and type' do
      packer = MessagePack::Packer.new
      packer.register_type(0x01, ValueOne, :to_msgpack_ext)
      packer.register_type(0x02, ValueTwo, :to_msgpack_ext)

      expect(packer.registered_types).to be_a(Array)
      expect(packer.registered_types.size).to eq(2)

      one = packer.registered_types[0]
      expect(one.keys.sort).to eq([:type, :class, :packer].sort)
      expect(one[:type]).to eq(0x01)
      expect(one[:class]).to eq(ValueOne)
      expect(one[:packer]).to eq(:to_msgpack_ext)

      two = packer.registered_types[1]
      expect(two.keys.sort).to eq([:type, :class, :packer].sort)
      expect(two[:type]).to eq(0x02)
      expect(two[:class]).to eq(ValueTwo)
      expect(two[:packer]).to eq(:to_msgpack_ext)
    end

    context 'when it has no ext type but a super class has' do
      before { stub_const('Value', Class.new) }
      before do
        Value.class_eval do
          def to_msgpack_ext
            'value_msgpacked'
          end
        end
      end
      before { packer.register_type(0x01, Value, :to_msgpack_ext) }

      context "when it is a child class" do
        before { stub_const('InheritedValue', Class.new(Value)) }
        subject { packer.pack(InheritedValue.new).to_s }

        it { is_expected.to eq "\xC7\x0F\x01value_msgpacked" }

        context "when it is a grandchild class" do
          before { stub_const('InheritedTwiceValue', Class.new(InheritedValue)) }
          subject { packer.pack(InheritedTwiceValue.new).to_s }

          it { is_expected.to eq "\xC7\x0F\x01value_msgpacked" }
        end
      end
    end

    context 'when it and its super class has an ext type' do
      before { stub_const('Value', Class.new) }
      before do
        Value.class_eval do
          def to_msgpack_ext
            'value_msgpacked'
          end
        end
      end
      before { packer.register_type(0x01, Value, :to_msgpack_ext) }

      context "when it is a child class" do
        before { stub_const('InheritedValue', Class.new(Value)) }
        before do
          InheritedValue.class_eval do
            def to_msgpack_ext
              'inherited_value_msgpacked'
            end
          end
        end

        before { packer.register_type(0x02, InheritedValue, :to_msgpack_ext) }
        subject { packer.pack(InheritedValue.new).to_s }

        it { is_expected.to eq "\xC7\x19\x02inherited_value_msgpacked" }
      end

      context "even when it is a child class" do
        before { stub_const('InheritedValue', Class.new(Value)) }
        before do
          InheritedValue.class_eval do
            def to_msgpack_ext
              'inherited_value_msgpacked'
            end
          end
        end

        before { packer.register_type(0x02, InheritedValue, :to_msgpack_ext) }
        subject { packer.pack(Value.new).to_s }

        it { is_expected.to eq "\xC7\x0F\x01value_msgpacked" }
      end
    end

    context 'when it has no ext type but an included module has' do
      subject { packer.pack(Value.new).to_s }

      before do
        mod = Module.new do
          def to_msgpack_ext
            'value_msgpacked'
          end
        end
        stub_const('Mod', mod)
      end
      before { packer.register_type(0x01, Mod, :to_msgpack_ext) }

      before { stub_const('Value', Class.new{ include Mod }) }

      it { is_expected.to eq "\xC7\x0F\x01value_msgpacked" }
    end

    context 'when it has no ext type but it was extended by a module which has one' do
      subject { packer.pack(object).to_s }
      let(:object) { Object.new.extend Mod }

      before do
        mod = Module.new do
          def to_msgpack_ext
            'value_msgpacked'
          end
        end
        stub_const('Mod', mod)
      end
      before { packer.register_type(0x01, Mod, :to_msgpack_ext) }


      it { is_expected.to eq "\xC7\x0F\x01value_msgpacked" }
    end

    context 'when registering a type for symbols' do
      before { packer.register_type(0x00, ::Symbol, :to_msgpack_ext) }

      it 'packs symbols in an ext type' do
        expect(packer.pack(:symbol).to_s).to eq "\xc7\x06\x00symbol"
      end
    end
  end

  describe "fixnum and bignum" do
    it "fixnum.to_msgpack" do
      23.to_msgpack.should == "\x17"
    end

    it "fixnum.to_msgpack(packer)" do
      23.to_msgpack(packer)
      packer.to_s.should == "\x17"
    end

    it "bignum.to_msgpack" do
      -4294967296.to_msgpack.should == "\xD3\xFF\xFF\xFF\xFF\x00\x00\x00\x00"
    end

    it "bignum.to_msgpack(packer)" do
      -4294967296.to_msgpack(packer)
      packer.to_s.should == "\xD3\xFF\xFF\xFF\xFF\x00\x00\x00\x00"
    end

    it "unpack(fixnum)" do
      MessagePack.unpack("\x17").should == 23
    end

    it "unpack(bignum)" do
      MessagePack.unpack("\xD3\xFF\xFF\xFF\xFF\x00\x00\x00\x00").should == -4294967296
    end
  end

  describe "ext formats" do
    [1, 2, 4, 8, 16].zip([0xd4, 0xd5, 0xd6, 0xd7, 0xd8]).each do |n,b|
      it "msgpack fixext #{n} format" do
        MessagePack::ExtensionValue.new(1, "a"*n).to_msgpack.should ==
          [b, 1].pack('CC') + "a"*n
      end
    end

    it "msgpack ext 8 format" do
      MessagePack::ExtensionValue.new(1, "").to_msgpack.should ==
        [0xc7, 0, 1].pack('CCC') + ""
      MessagePack::ExtensionValue.new(-1, "a"*255).to_msgpack.should ==
        [0xc7, 255, -1].pack('CCC') + "a"*255
    end

    it "msgpack ext 16 format" do
      MessagePack::ExtensionValue.new(1, "a"*256).to_msgpack.should ==
        [0xc8, 256, 1].pack('CnC') + "a"*256
      MessagePack::ExtensionValue.new(-1, "a"*65535).to_msgpack.should ==
        [0xc8, 65535, -1].pack('CnC') + "a"*65535
    end

    it "msgpack ext 32 format" do
      MessagePack::ExtensionValue.new(1, "a"*65536).to_msgpack.should ==
        [0xc9, 65536, 1].pack('CNC') + "a"*65536
      MessagePack::ExtensionValue.new(-1, "a"*65538).to_msgpack.should ==
        [0xc9, 65538, -1].pack('CNC') + "a"*65538
    end
  end
end
