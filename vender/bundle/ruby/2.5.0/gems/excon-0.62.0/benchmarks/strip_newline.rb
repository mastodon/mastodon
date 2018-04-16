# require 'benchmark'
# 
# COUNT = 1_000_000
# data = "Content-Length: 100\r\n"
# Benchmark.bmbm(25) do |bench|
#   bench.report('chomp') do
#     COUNT.times do
#       data = "Content-Length: 100\r\n"
#       data.chomp
#     end
#   end
#   bench.report('chomp!') do
#     COUNT.times do
#       data = "Content-Length: 100\r\n"
#       data.chomp!
#     end
#   end
#   bench.report('chop') do
#     COUNT.times do
#       data = "Content-Length: 100\r\n"
#       data.chop
#     end
#   end
#   bench.report('chop!') do
#     COUNT.times do
#       data = "Content-Length: 100\r\n"
#       data.chop!
#     end
#   end
#   bench.report('strip') do
#     COUNT.times do
#       data = "Content-Length: 100\r\n"
#       data.strip
#     end
#   end
#   bench.report('strip!') do
#     COUNT.times do
#       data = "Content-Length: 100\r\n"
#       data.strip!
#     end
#   end
#   bench.report('index') do
#     COUNT.times do
#       data = "Content-Length: 100\r\n"
#       data[0..-3]
#     end
#   end
# end



# Rehearsal ------------------------------------------------------------
# chomp                      0.640000   0.000000   0.640000 (  0.644043)
# chomp!                     0.530000   0.000000   0.530000 (  0.531415)
# chop                       0.620000   0.000000   0.620000 (  0.624321)
# chop!                      0.500000   0.000000   0.500000 (  0.509146)
# strip                      0.640000   0.000000   0.640000 (  0.638785)
# strip!                     0.530000   0.000000   0.530000 (  0.532196)
# index                      0.740000   0.000000   0.740000 (  0.745742)
# --------------------------------------------------- total: 4.200000sec
# 
#                                user     system      total        real
# chomp                      0.640000   0.010000   0.650000 (  0.647287)
# chomp!                     0.530000   0.000000   0.530000 (  0.532868)
# chop                       0.630000   0.000000   0.630000 (  0.628236)
# chop!                      0.520000   0.000000   0.520000 (  0.522950)
# strip                      0.640000   0.000000   0.640000 (  0.646328)
# strip!                     0.520000   0.000000   0.520000 (  0.532715)
# index                      0.740000   0.010000   0.750000 (  0.771277)

require 'rubygems'
require 'tach'

data = "Content-Length: 100\r\n"
Tach.meter(1_000_000) do
  tach('chomp') do
    data.dup.chomp
  end
  tach('chomp!') do
    data.dup.chomp!
  end
  tach('chop') do
    data.dup.chop
  end
  tach('chop!') do
    data.dup.chop!
  end
  tach('strip') do
    data.dup.strip
  end
  tach('strip!') do
    data.dup.strip!
  end
  tach('index') do
    data.dup[0..-3]
  end
end

# +--------+----------+----------+
# | tach   | average  | total    |
# +--------+----------+----------+
# | chomp  | 1.444547 | 1.444547 |
# +--------+----------+----------+
# | chomp! | 1.276813 | 1.276813 |
# +--------+----------+----------+
# | chop   | 1.422744 | 1.422744 |
# +--------+----------+----------+
# | chop!  | 1.240941 | 1.240941 |
# +--------+----------+----------+
# | strip  | 1.444776 | 1.444776 |
# +--------+----------+----------+
# | strip! | 1.266459 | 1.266459 |
# +--------+----------+----------+
# | index  | 1.557975 | 1.557975 |
# +--------+----------+----------+