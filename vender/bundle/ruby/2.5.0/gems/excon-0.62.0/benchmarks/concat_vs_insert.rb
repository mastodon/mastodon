require 'rubygems'
require 'tach'

Tach.meter(1_000_000) do
  tach('concat') do
    path = 'path'
    path = '/' << path
  end
  tach('insert') do
    path = 'path'
    path.insert(0, '/')
  end
end

# +--------+----------+
# | tach   | total    |
# +--------+----------+
# | insert | 0.974036 |
# +--------+----------+
# | concat | 0.998904 |
# +--------+----------+