require 'rubygems'
require 'tach'

class Concatenator
  def initialize(string)
    @string = string
  end

  def call(data)
    @string << data
  end
end

string = "0123456789ABCDEF"

Tach.meter(100_000) do
  tach('class') do
    s = ""
    obj = Concatenator.new(s)
    10.times { obj.call(string) }
  end

  tach('lambda') do
    s = ""
    obj = lambda {|data| s << data }
    10.times { obj.call(string) }
  end
end

# ruby 1.9.2p136 (2010-12-25 revision 30365) [x86_64-linux]
#
#  +--------+----------+
#  | tach   | total    |
#  +--------+----------+
#  | class  | 1.450284 |
#  +--------+----------+
#  | lambda | 2.506496 |
#  +--------+----------+

# ruby 1.8.7 (2010-12-23 patchlevel 330) [x86_64-linux]
#
#  +--------+----------+
#  | tach   | total    |
#  +--------+----------+
#  | class  | 1.373917 |
#  +--------+----------+
#  | lambda | 2.589384 |
#  +--------+----------+
  

