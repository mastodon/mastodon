require 'hkdf'

RSpec.configure do |config|
  config.order = 'random'
end

def test_vectors
  test_parts = File.readlines('spec/fixtures/test_vectors.txt').
    map(&:strip).
    reject(&:empty?).
    each_slice(8)

  test_parts.reduce({}) do |vectors, lines|
    name = lines.shift
    values = lines.reduce({}) do |hash, line|
      key, value = line.split('=').map(&:strip)
      value = '' unless value
      value = [value.slice(2..-1)].pack('H*') if value.start_with?('0x')
      hash.merge(key.to_sym => value)
    end
    vectors.merge(name => values)
  end
end
