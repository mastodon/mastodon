require 'rubygems'
require 'tach'

key = 'Content-Length'
value = '100'
Tach.meter(1_000) do
  tach('concat') do
    temp = ''
    temp << key << ': ' << value << "\r\n"
  end
  tach('interpolate') do
    "#{key}: #{value}\r\n"
  end
end

# +-------------+----------+
# | tach        | total    |
# +-------------+----------+
# | interpolate | 0.000404 |
# +-------------+----------+
# | concat      | 0.000564 |
# +-------------+----------+
