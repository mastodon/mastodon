#!/usr/bin/env ruby

$: << '.'
$: << '../lib'
$: << '../ext'

require 'oj'
require 'sample'

#obj = sample_doc(1)

class Foo
  def initialize()
    @x = 'abc'
    @y = 123
    @a = [{}]
  end
end

obj = Foo.new
obj = {
  x: 'abc',
  y: 123,
  a: [{}]
}

j = Oj.dump(obj, mode: :rails, trace: true)
#j = Oj.dump(obj, mode: :compat)

puts j

Oj.load(j, mode: :rails, trace: true)
