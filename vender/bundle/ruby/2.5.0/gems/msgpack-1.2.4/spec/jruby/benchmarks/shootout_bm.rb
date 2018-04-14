# encoding: utf-8

if RUBY_PLATFORM.include?('java')
  # JRuby should use this library, MRI should use the standard gem
  $: << File.expand_path('../../../lib', __FILE__)
end

require 'viiite'
require 'msgpack'
require 'json'
require 'bson'

if RUBY_PLATFORM.include?('java')
  BSON_IMPL = BSON::BSON_JAVA
else
  BSON_IMPL = BSON::BSON_C
end

OBJECT_STRUCTURE = {'x' => ['y', 34, 2**30 + 3, 2.1223423423356, {'hello' => 'world', '5' => [63, 'asjdl']}]}
ENCODED_MSGPACK = "\x81\xA1x\x95\xA1y\"\xCE@\x00\x00\x03\xCB@\x00\xFA\x8E\x9F9\xFA\xC1\x82\xA5hello\xA5world\xA15\x92?\xA5asjdl"
ENCODED_BSON = "d\x00\x00\x00\x04x\x00\\\x00\x00\x00\x020\x00\x02\x00\x00\x00y\x00\x101\x00\"\x00\x00\x00\x102\x00\x03\x00\x00@\x013\x00\xC1\xFA9\x9F\x8E\xFA\x00@\x034\x002\x00\x00\x00\x02hello\x00\x06\x00\x00\x00world\x00\x045\x00\x19\x00\x00\x00\x100\x00?\x00\x00\x00\x021\x00\x06\x00\x00\x00asjdl\x00\x00\x00\x00\x00"
ENCODED_JSON = '{"x":["y",34,1073741827,2.1223423423356,{"hello":"world","5":[63,"asjdl"]}]}'
ITERATIONS = 1_00_000
IMPLEMENTATIONS = ENV.fetch('IMPLEMENTATIONS', 'json,bson,msgpack').split(',').map(&:to_sym)

Viiite.bm do |b|
  b.variation_point :ruby, Viiite.which_ruby
  
  IMPLEMENTATIONS.each do |lib|
    b.variation_point :lib, lib
    
  
    b.report(:pack) do
      ITERATIONS.times do
        case lib
        when :msgpack then MessagePack.pack(OBJECT_STRUCTURE)
        when :bson then BSON_IMPL.serialize(OBJECT_STRUCTURE).to_s
        when :json then OBJECT_STRUCTURE.to_json
        end
      end
    end
  
    b.report(:unpack) do
      ITERATIONS.times do
        case lib
        when :msgpack then MessagePack.unpack(ENCODED_MSGPACK)
        when :bson then BSON_IMPL.deserialize(ENCODED_BSON)
        when :json then JSON.parse(ENCODED_JSON)
        end
      end
    end
    
    b.report(:pack_unpack) do
      ITERATIONS.times do
        case lib
        when :msgpack then MessagePack.unpack(MessagePack.pack(OBJECT_STRUCTURE))
        when :bson then BSON_IMPL.deserialize(BSON_IMPL.serialize(OBJECT_STRUCTURE).to_s)
        when :json then JSON.parse(OBJECT_STRUCTURE.to_json)
        end
      end
    end

    b.report(:unpack_pack) do
      ITERATIONS.times do
        case lib
        when :msgpack then MessagePack.pack(MessagePack.unpack(ENCODED_MSGPACK))
        when :bson then BSON_IMPL.serialize(BSON_IMPL.deserialize(ENCODED_BSON)).to_s
        when :json then OBJECT_STRUCTURE.to_json(JSON.parse(ENCODED_JSON))
        end
      end
    end
  end
end