require 'openssl'
require 'stringio'

class HKDF
  DefaultAlgorithm = 'SHA256'
  DefaultReadSize = 512 * 1024

  def initialize(source, options = {})
    source = StringIO.new(source) if source.is_a?(String)

    algorithm = options.fetch(:algorithm, DefaultAlgorithm)
    @digest = OpenSSL::Digest.new(algorithm)
    @info = options.fetch(:info, '')

    salt = options[:salt]
    salt = 0.chr * @digest.digest_length if salt.nil? or salt.empty?
    read_size = options.fetch(:read_size, DefaultReadSize)

    @prk = _generate_prk(salt, source, read_size)
    @position = 0
    @blocks = []
    @blocks << ''
  end

  def algorithm
    @digest.name
  end

  def max_length
    @max_length ||= @digest.digest_length * 255
  end

  def seek(position)
    raise RangeError.new("cannot seek past #{max_length}") if position > max_length

    @position = position
  end

  def rewind
    seek(0)
  end

  def next_bytes(length)
    new_position = length + @position
    raise RangeError.new("requested #{length} bytes, only #{max_length} available") if new_position > max_length

    _generate_blocks(new_position)

    start = @position
    @position = new_position

    @blocks.join('').slice(start, length)
  end

  def next_hex_bytes(length)
    next_bytes(length).unpack('H*').first
  end

  def inspect
    "#{to_s[0..-2]} algorithm=#{@digest.name.inspect} info=#{@info.inspect}>"
  end

  def _generate_prk(salt, source, read_size)
    hmac = OpenSSL::HMAC.new(salt, @digest)
    while block = source.read(read_size)
      hmac.update(block)
    end
    hmac.digest
  end

  def _generate_blocks(length)
    start = @blocks.size
    block_count = (length.to_f / @digest.digest_length).ceil
    start.upto(block_count) do |n|
      @blocks << OpenSSL::HMAC.digest(@digest, @prk, @blocks[n - 1] + @info + n.chr)
    end
  end
end
