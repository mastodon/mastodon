require 'rubygems'
require 'tach'

Tach.meter(1_000_000) do
  tach('double') do
    "path"
  end
  tach('single') do
    'path'
  end
end

#  [double, single]
#
#  +--------+----------+
#  | tach   | total    |
#  +--------+----------+
#  | single | 0.416340 |
#  +--------+----------+
#  | double | 0.416570 |
#  +--------+----------+
