# encoding: UTF-8
$KCODE = 'u' unless "1.9".respond_to?(:encoding)

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
require "htmlentities"

class HTMLEntitiesJob
  def initialize
    @coder = HTMLEntities.new
    @decoded = File.read(File.join(File.dirname(__FILE__), "sample"))
    @encoded = @coder.encode(@decoded, :basic, :named, :hexadecimal)
  end

  def encode(cycles)
    cycles.times do
      @coder.encode(@decoded, :basic, :named, :hexadecimal)
      @coder.encode(@decoded, :basic, :named, :decimal)
    end
  end

  def decode(cycles)
    cycles.times do
      @coder.decode(@encoded)
    end
  end

  def all(cycles)
    encode(cycles)
    decode(cycles)
  end
end
