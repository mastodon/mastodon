class Symbol
  def to_msgpack_ext
    [to_s].pack('A*')
  end

  def self.from_msgpack_ext(data)
    data.unpack('A*').first.to_sym
  end
end