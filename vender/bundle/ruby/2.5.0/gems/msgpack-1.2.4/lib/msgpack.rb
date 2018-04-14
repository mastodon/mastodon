require "msgpack/version"

if defined?(RUBY_ENGINE) && RUBY_ENGINE == "jruby" # This is same with `/java/ =~ RUBY_VERSION`
  require "java"
  require "msgpack/msgpack.jar"
  org.msgpack.jruby.MessagePackLibrary.new.load(JRuby.runtime, false)
else
  begin
    require "msgpack/#{RUBY_VERSION[/\d+.\d+/]}/msgpack"
  rescue LoadError
    require "msgpack/msgpack"
  end
end

require "msgpack/packer"
require "msgpack/unpacker"
require "msgpack/factory"
require "msgpack/symbol"
require "msgpack/core_ext"

module MessagePack
  DefaultFactory = MessagePack::Factory.new

  def load(src, param = nil)
    unpacker = nil

    if src.is_a? String
      unpacker = DefaultFactory.unpacker param
      unpacker.feed src
    else
      unpacker = DefaultFactory.unpacker src, param
    end

    unpacker.full_unpack
  end
  alias :unpack :load

  module_function :load
  module_function :unpack

  def pack(v, *rest)
    packer = DefaultFactory.packer(*rest)
    packer.write v
    packer.full_pack
  end
  alias :dump :pack

  module_function :pack
  module_function :dump
end
