# encoding: ascii-8bit

require 'spec_helper'

def utf8enc(str)
  str.encode('UTF-8')
end

def asciienc(str)
  str.encode('ASCII-8BIT')
end

describe MessagePack do
  tests = {
    'constant values' => [
      ['true', true, "\xC3"],
      ['false', false, "\xC2"],
      ['nil', nil, "\xC0"]
    ],
    'numbers' => [
      ['zero', 0, "\x00"],
      ['127', 127, "\x7F"],
      ['128', 128, "\xCC\x80"],
      ['256', 256, "\xCD\x01\x00"],
      ['-1', -1, "\xFF"],
      ['-33', -33, "\xD0\xDF"],
      ['-129', -129, "\xD1\xFF\x7F"],
      ['small integers', 42, "*"],
      ['medium integers', 333, "\xCD\x01M"],
      ['large integers', 2**31 - 1, "\xCE\x7F\xFF\xFF\xFF"],
      ['huge integers', 2**64 - 1, "\xCF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"],
      ['negative integers', -1, "\xFF"],
      ['1.0', 1.0, "\xcb\x3f\xf0\x00\x00\x00\x00\x00\x00"],
      ['small floats', 3.14, "\xCB@\t\x1E\xB8Q\xEB\x85\x1F"],
      ['big floats', Math::PI * 1_000_000_000_000_000_000, "\xCBC\xC5\xCC\x96\xEF\xD1\x19%"],
      ['negative floats', -2.1, "\xCB\xC0\x00\xCC\xCC\xCC\xCC\xCC\xCD"]
    ],
    'strings' => [
      ['tiny strings', utf8enc('hello world'), "\xABhello world"],
      ['short strings', utf8enc('hello' * 5), "\xB9hellohellohellohellohello"],
      ['empty strings', utf8enc(''), "\xA0"]
    ],
    'binary strings' => [
      ['tiny strings', asciienc('hello world'), "\xC4\vhello world"],
      ['short strings', asciienc('hello' * 5), "\xC4\x19hellohellohellohellohello"],
      ['empty strings', asciienc(''), "\xC4\x00"]
    ],
    'arrays' => [
      ['empty arrays', [], "\x90"],
      ['arrays with strings', [utf8enc("hello"), utf8enc("world")], "\x92\xA5hello\xA5world"],
      ['arrays with mixed values', [utf8enc("hello"), utf8enc("world"), 42], "\x93\xA5hello\xA5world*"],
      ['arrays of arrays', [[[[1, 2], 3], 4]], "\x91\x92\x92\x92\x01\x02\x03\x04"],
      ['empty arrays', [], "\x90"]
    ],
    'hashes' => [
      ['empty hashes', {}, "\x80"],
      ['hashes', {utf8enc('foo') => utf8enc('bar')}, "\x81\xA3foo\xA3bar"],
      ['hashes with mixed keys and values', {utf8enc('foo') => utf8enc('bar'), 3 => utf8enc('three'), utf8enc('four') => 4, utf8enc('x') => [utf8enc('y')], utf8enc('a') => utf8enc('b')}, "\x85\xA3foo\xA3bar\x03\xA5three\xA4four\x04\xA1x\x91\xA1y\xA1a\xA1b"],
      ['hashes of hashes', {{utf8enc('x') => {utf8enc('y') => utf8enc('z')}} => utf8enc('s')}, "\x81\x81\xA1x\x81\xA1y\xA1z\xA1s"],
      ['hashes with nils', {utf8enc('foo') => nil}, "\x81\xA3foo\xC0"]
    ]
  }

  tests.each do |ctx, its|
    context("with #{ctx}") do
      its.each do |desc, unpacked, packed|
        it("encodes #{desc}") do
          MessagePack.pack(unpacked).should == packed
        end

        it "decodes #{desc}" do
          MessagePack.unpack(packed).should == unpacked
        end
      end
    end
  end

  context 'using other names for .pack and .unpack' do
    it 'can unpack with .load' do
      MessagePack.load("\xABhello world").should == 'hello world'
    end

    it 'can pack with .dump' do
      MessagePack.dump(utf8enc('hello world')).should == "\xABhello world"
    end
  end

  context 'with symbols' do
    it 'encodes symbols as strings' do
      MessagePack.pack(:symbol).should == "\xA6symbol"
    end
  end

  context 'with different external encoding', :encodings do
    before do
      @default_external = Encoding.default_external
      @default_internal = Encoding.default_internal
      Encoding.default_external = Encoding::UTF_8
      Encoding.default_internal = Encoding::ISO_8859_1
    end

    after do
      Encoding.default_external = @default_external
      Encoding.default_internal = @default_internal
    end

    it 'transcodes strings when encoding' do
      input = "sk\xE5l".force_encoding(Encoding::ISO_8859_1)
      MessagePack.pack(input).should == "\xA5sk\xC3\xA5l"
    end
  end

  context 'with other things' do
    it 'raises an error on #pack with an unsupported type' do
      expect { MessagePack.pack(self) }.to raise_error(NoMethodError, /^undefined method `to_msgpack'/)
    end

    it 'rasies an error on #unpack with garbage' do
      skip "but nothing was raised. why?"
      expect { MessagePack.unpack('asdka;sd') }.to raise_error(MessagePack::UnpackError)
    end
  end

  context 'extensions' do
    it 'can unpack hashes with symbolized keys' do
      packed = MessagePack.pack({'hello' => 'world', 'nested' => ['object', {'structure' => true}]})
      unpacked = MessagePack.unpack(packed, :symbolize_keys => true)
      unpacked.should == {:hello => 'world', :nested => ['object', {:structure => true}]}
    end

    it 'does not symbolize keys even if other options are present' do
      packed = MessagePack.pack({'hello' => 'world', 'nested' => ['object', {'structure' => true}]})
      unpacked = MessagePack.unpack(packed, :other_option => false)
      unpacked.should == {'hello' => 'world', 'nested' => ['object', {'structure' => true}]}
    end

    it 'can unpack strings with a specified encoding', :encodings do
      packed = MessagePack.pack({utf8enc('hello') => utf8enc('world')})
      unpacked = MessagePack.unpack(packed)
      unpacked['hello'].encoding.should == Encoding::UTF_8
    end

    it 'can pack strings with a specified encoding', :encodings do
      packed = MessagePack.pack({'hello' => "w\xE5rld".force_encoding(Encoding::ISO_8859_1)})
      packed.index("w\xC3\xA5rld").should_not be_nil
    end
  end

  context 'in compatibility mode' do
    it 'does not use the bin types' do
      packed = MessagePack.pack('hello'.force_encoding(Encoding::BINARY), compatibility_mode: true)
      packed.should eq("\xA5hello")
      packed = MessagePack.pack(('hello' * 100).force_encoding(Encoding::BINARY), compatibility_mode: true)
      packed.should start_with("\xDA\x01\xF4")
    end

    it 'does not use the str8 type' do
      packed = MessagePack.pack('x' * 32, compatibility_mode: true)
      packed.should start_with("\xDA\x00\x20")
    end
  end

  context 'when a Bignum has a small value' do
    tests['numbers'].take(10).each do |desc, unpacked, packed|
      it("encodes #{desc} to the smallest representation") do
        bignum = (1 << 64).coerce(unpacked)[0]
        MessagePack.pack(bignum).should eq(packed)
      end
    end
  end
end
