require 'rubygems'
require 'tach'

data = "Content-Length: 100"
Tach.meter(1_000_000) do
  tach('regex') do
    data.match(/(.*):\s(.*)/)
    header = [$1, $2]
  end
  tach('split') do
    header = data.split(': ', 2)
  end
  tach('split regex') do
    header = data.split(/:\s*/, 2)
  end
end

#  +-------------+----------+
#  | tach        | total    |
#  +-------------+----------+
#  | split regex | 5.940233 |
#  +-------------+----------+
#  | split       | 7.327549 |
#  +-------------+----------+
#  | regex       | 8.736390 |
#  +-------------+----------+

# +-------+----------+----------+
# | tach  | average  | total    |
# +-------+----------+----------+
# | regex | 4.680451 | 4.680451 |
# +-------+----------+----------+
# | split | 4.393218 | 4.393218 |
# +-------+----------+----------+
