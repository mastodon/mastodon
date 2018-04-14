require 'set'

# MIME::Types requires a container Hash with a default values for keys
# resulting in an empty array (<tt>[]</tt>), but this cannot be dumped through
# Marshal because of the presence of that default Proc. This class exists
# solely to satisfy that need.
class MIME::Types::Container < Hash # :nodoc:
  def initialize
    super
    self.default_proc = ->(h, k) { h[k] = Set.new }
  end

  def marshal_dump
    {}.merge(self)
  end

  def marshal_load(hash)
    self.default_proc = ->(h, k) { h[k] = Set.new }
    merge!(hash)
  end

  def encode_with(coder)
    each { |k, v| coder[k] = v.to_a }
  end

  def init_with(coder)
    self.default_proc = ->(h, k) { h[k] = Set.new }
    coder.map.each { |k, v| self[k] = Set[*v] }
  end
end
