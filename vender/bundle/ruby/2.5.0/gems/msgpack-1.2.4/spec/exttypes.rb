class DummyTimeStamp1
  TYPE = 15

  attr_reader :utime, :usec, :time

  def initialize(utime, usec)
    @utime = utime
    @usec = usec
    @time = Time.at(utime, usec)
  end

  def ==(other)
    self.utime == other.utime && self.usec == other.usec
  end

  def self.type_id
    15
  end

  def self.from_msgpack_ext(data)
    new(*data.unpack('I*'))
  end

  def to_msgpack_ext
    [@utime,@usec].pack('I*')
  end
end

class DummyTimeStamp2
  TYPE = 16

  attr_reader :utime, :usec, :time

  def initialize(utime, usec)
    @utime = utime
    @usec = usec
    @time = Time.at(utime, usec)
  end

  def ==(other)
    self.utime == other.utime && self.usec == other.usec
  end

  def self.deserialize(data)
    new(* data.split(',', 2).map(&:to_i))
  end

  def serialize
    [@utime,@usec].map(&:to_s).join(',')
  end
end
