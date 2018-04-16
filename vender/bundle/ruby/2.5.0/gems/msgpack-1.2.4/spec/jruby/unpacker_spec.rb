# encoding: ascii-8bit

require 'stringio'
require 'tempfile'

require 'spec_helper'

describe MessagePack::Unpacker do
  let :unpacker do
    MessagePack::Unpacker.new
  end

  let :packer do
    MessagePack::Packer.new
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

  describe '#execute/#execute_limit/#finished?' do
    let :buffer do
      buffer1 + buffer2 + buffer3
    end

    it 'extracts an object from the buffer' do
      subject.execute(buffer, 0)
      subject.data.should == {'foo' => 'bar'}
    end

    it 'extracts an object from the buffer, starting at an offset' do
      subject.execute(buffer, buffer1.length)
      subject.data.should == {'hello' => {'world' => [1, 2, 3]}}
    end

    it 'extracts an object from the buffer, starting at an offset reading bytes up to a limit' do
      subject.execute_limit(buffer, buffer1.length, buffer2.length)
      subject.data.should == {'hello' => {'world' => [1, 2, 3]}}
    end

    it 'extracts nothing if the limit cuts an object in half' do
      subject.execute_limit(buffer, buffer1.length, 3)
      subject.data.should be_nil
    end

    it 'returns the offset where the object ended' do
      subject.execute(buffer, 0).should == buffer1.length
      subject.execute(buffer, buffer1.length).should == buffer1.length + buffer2.length
    end

    it 'is finished if #data returns an object' do
      subject.execute_limit(buffer, buffer1.length, buffer2.length)
      subject.should be_finished

      subject.execute_limit(buffer, buffer1.length, 3)
      subject.should_not be_finished
    end
  end

  describe '#each' do
    context 'with a StringIO stream' do
      it 'yields each object in the stream' do
        objects = []
        subject.stream = StringIO.new(buffer1 + buffer2 + buffer3)
        subject.each do |obj|
          objects << obj
        end
        objects.should == [{'foo' => 'bar'}, {'hello' => {'world' => [1, 2, 3]}}, {'x' => 'y'}]
      end
    end

    context 'with a File stream' do
      it 'yields each object in the stream' do
        objects = []
        file = Tempfile.new('msgpack')
        file.write(buffer1)
        file.write(buffer2)
        file.write(buffer3)
        file.open
        subject.stream = file
        subject.each do |obj|
          objects << obj
        end
        objects.should == [{'foo' => 'bar'}, {'hello' => {'world' => [1, 2, 3]}}, {'x' => 'y'}]
      end
    end
  end

  describe '#fill' do
    it 'is a no-op' do
      subject.stream = StringIO.new(buffer1 + buffer2 + buffer3)
      subject.fill
      subject.each { |obj| }
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

  context 'encoding', :encodings do
    before :all do
      @default_internal = Encoding.default_internal
      @default_external = Encoding.default_external
    end

    after :all do
      Encoding.default_internal = @default_internal
      Encoding.default_external = @default_external
    end

    let :buffer do
      MessagePack.pack({'hello' => 'world', 'nested' => ['object', {"sk\xC3\xA5l".force_encoding('utf-8') => true}]})
    end

    let :unpacker do
      described_class.new
    end

    before do
      Encoding.default_internal = Encoding::UTF_8
      Encoding.default_external = Encoding::ISO_8859_1
    end

    it 'produces results with encoding as binary or string(utf8)' do
      unpacker.execute(buffer, 0)
      strings = flatten(unpacker.data).grep(String)
      strings.map(&:encoding).uniq.sort{|a,b| a.to_s <=> b.to_s}.should == [Encoding::ASCII_8BIT, Encoding::UTF_8]
    end

    it 'recodes to internal encoding' do
      unpacker.execute(buffer, 0)
      unpacker.data['nested'][1].keys.should == ["sk\xC3\xA5l".force_encoding(Encoding::UTF_8)]
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

      it 'can symbolize keys when using #execute' do
        unpacker.execute(buffer, 0)
        unpacker.data.should == {:hello => 'world', :nested => ['object', {:structure => true}]}
      end
    end

    context 'encoding', :encodings do
      let :buffer do
        MessagePack.pack({'hello' => 'world', 'nested' => ['object', {'structure' => true}]})
      end

      let :unpacker do
        described_class.new()
      end

      it 'decode binary as ascii-8bit string when using #execute' do
        unpacker.execute(buffer, 0)
        strings = flatten(unpacker.data).grep(String)
        strings.should == %w[hello world nested object structure]
        strings.map(&:encoding).uniq.should == [Encoding::ASCII_8BIT]
      end
    end
  end
end
