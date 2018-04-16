require 'bootsnap/bootsnap'

module Bootsnap
  module CompileCache
    module YAML
      class << self
        attr_accessor :msgpack_factory
      end

      def self.input_to_storage(contents, _)
        raise Uncompilable if contents.index("!ruby/object")
        obj = ::YAML.load(contents)
        msgpack_factory.packer.write(obj).to_s
      rescue NoMethodError, RangeError
        # if the object included things that we can't serialize, fall back to
        # Marshal. It's a bit slower, but can encode anything yaml can.
        # NoMethodError is unexpected types; RangeError is Bignums
        return Marshal.dump(obj)
      end

      def self.storage_to_output(data)
        # This could have a meaning in messagepack, and we're being a little lazy
        # about it. -- but a leading 0x04 would indicate the contents of the YAML
        # is a positive integer, which is rare, to say the least.
        if data[0] == 0x04.chr && data[1] == 0x08.chr
          Marshal.load(data)
        else
          msgpack_factory.unpacker.feed(data).read
        end
      end

      def self.input_to_output(data)
        ::YAML.load(data)
      end

      def self.install!(cache_dir)
        require 'yaml'
        require 'msgpack'

        # MessagePack serializes symbols as strings by default.
        # We want them to roundtrip cleanly, so we use a custom factory.
        # see: https://github.com/msgpack/msgpack-ruby/pull/122
        factory = MessagePack::Factory.new
        factory.register_type(0x00, Symbol)
        Bootsnap::CompileCache::YAML.msgpack_factory = factory

        klass = class << ::YAML; self; end
        klass.send(:define_method, :load_file) do |path|
          Bootsnap::CompileCache::Native.fetch(
            cache_dir,
            path.to_s,
            Bootsnap::CompileCache::YAML
          )
        end
      end
    end
  end
end
