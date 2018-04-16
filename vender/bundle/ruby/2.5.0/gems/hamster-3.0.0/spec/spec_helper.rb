require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require "pry"
require "rspec"
require "hamster/hash"
require "hamster/set"
require "hamster/vector"
require "hamster/sorted_set"
require "hamster/list"
require "hamster/deque"
require "hamster/core_ext"

# Suppress warnings from use of old RSpec expectation and mock syntax
# If all tests are eventually updated to use the new syntax, this can be removed
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

V = Hamster::Vector
L = Hamster::List
H = Hamster::Hash
S = Hamster::Set
SS = Hamster::SortedSet
D = Hamster::Deque
EmptyList = Hamster::EmptyList

Struct.new("Customer", :name, :address)

def fixture(name)
  File.read(fixture_path(name))
end

def fixture_path(name)
  File.join("spec", "fixtures", name)
end

if RUBY_ENGINE == "ruby"
  def calculate_stack_overflow_depth(n)
    calculate_stack_overflow_depth(n + 1)
  rescue SystemStackError
    n
  end
  STACK_OVERFLOW_DEPTH = calculate_stack_overflow_depth(2)
else
  STACK_OVERFLOW_DEPTH = 16_384
end

class DeterministicHash
  attr_reader :hash, :value

  def initialize(value, hash)
    @value = value
    @hash = hash
  end

  def to_s
    @value.to_s
  end

  def inspect
    @value.inspect
  end

  def ==(other)
    other.is_a?(DeterministicHash) && self.value == other.value
  end
  alias :eql? :==

  def <=>(other)
    self.value <=> other.value
  end
end

class EqualNotEql
  def ==(other)
    true
  end
  def eql?(other)
    false
  end
end

class EqlNotEqual
  def ==(other)
    false
  end
  def eql?(other)
    true
  end
end
