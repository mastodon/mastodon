require 'rubygems'
require 'tach'

CR_LF = "\r\n"

Tach.meter(1_000_000) do
  tach('constant') do
    '' << CR_LF
  end
  tach('string') do
    '' << "\r\n"
  end
end

# +----------+----------+
# | tach     | total    |
# +----------+----------+
# | constant | 0.819885 |
# +----------+----------+
# | string   | 0.893602 |
# +----------+----------+