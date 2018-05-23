# frozen_string_literal: true

require "stringio"

class FakeIO
  def initialize(content)
    @io = StringIO.new(content)
  end

  def string
    @io.string
  end

  def read(*args)
    @io.read(*args)
  end

  def size
    @io.size
  end
end
