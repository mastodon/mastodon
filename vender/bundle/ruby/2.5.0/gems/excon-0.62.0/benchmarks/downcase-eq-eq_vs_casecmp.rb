# Copied from my benchmark_hell repo: github.com/sgonyea/benchmark_hell

require 'benchmark'

iters = 1000000

comp  = "hello"
hello = "HelLo"

puts 'String#downcase == vs. String#casecmp'
Benchmark.bmbm do |x|
  x.report('String#downcase1') do
    iters.times.each do
      hello.downcase == comp
    end
  end

  x.report('String#downcase2') do
    iters.times.each do
      "HelLo".downcase == "hello"
    end
  end

  x.report('String#downcase3') do
    iters.times.each do
      var = "HelLo"
      var.downcase!
      var == "hello"
    end
  end

  x.report('casecmp1') do
    iters.times.each do
      hello.casecmp(comp).zero?
    end
  end

  x.report('casecmp1-1') do
    iters.times.each do
      hello.casecmp(comp) == 0
    end
  end

  x.report('casecmp2') do
    iters.times.each do
      "HelLo".casecmp(comp).zero?
    end
  end

  x.report('casecmp2-1') do
    iters.times.each do
      "HelLo".casecmp(comp) == 0
    end
  end
end

=begin
rvm exec bash -c 'echo && echo $RUBY_VERSION && echo && ruby downcase-eq-eq_vs_casecmp.rb'

jruby-1.5.6

String#downcase == vs. String#casecmp
Rehearsal ----------------------------------------------------
String#downcase1   0.461000   0.000000   0.461000 (  0.387000)
String#downcase2   0.269000   0.000000   0.269000 (  0.269000)
String#downcase3   0.224000   0.000000   0.224000 (  0.224000)
casecmp1           0.157000   0.000000   0.157000 (  0.157000)
casecmp1-1         0.153000   0.000000   0.153000 (  0.153000)
casecmp2           0.163000   0.000000   0.163000 (  0.163000)
casecmp2-1         0.163000   0.000000   0.163000 (  0.163000)
------------------------------------------- total: 1.590000sec

                       user     system      total        real
String#downcase1   0.190000   0.000000   0.190000 (  0.191000)
String#downcase2   0.225000   0.000000   0.225000 (  0.225000)
String#downcase3   0.190000   0.000000   0.190000 (  0.190000)
casecmp1           0.125000   0.000000   0.125000 (  0.125000)
casecmp1-1         0.127000   0.000000   0.127000 (  0.127000)
casecmp2           0.144000   0.000000   0.144000 (  0.144000)
casecmp2-1         0.147000   0.000000   0.147000 (  0.147000)

macruby-0.7.1

String#downcase == vs. String#casecmp
Rehearsal ----------------------------------------------------
String#downcase1   2.340000   0.040000   2.380000 (  1.765141)
String#downcase2   5.510000   0.100000   5.610000 (  3.893249)
String#downcase3   4.200000   0.080000   4.280000 (  3.031621)
casecmp1           0.270000   0.000000   0.270000 (  0.267613)
casecmp1-1         0.190000   0.000000   0.190000 (  0.188848)
casecmp2           1.450000   0.020000   1.470000 (  1.027956)
casecmp2-1         1.380000   0.030000   1.410000 (  0.951474)
------------------------------------------ total: 15.610000sec

                       user     system      total        real
String#downcase1   2.350000   0.040000   2.390000 (  1.774292)
String#downcase2   5.890000   0.120000   6.010000 (  4.214038)
String#downcase3   4.530000   0.090000   4.620000 (  3.286059)
casecmp1           0.270000   0.000000   0.270000 (  0.271119)
casecmp1-1         0.190000   0.000000   0.190000 (  0.189462)
casecmp2           1.540000   0.030000   1.570000 (  1.104751)
casecmp2-1         1.440000   0.030000   1.470000 (  0.999689)

rbx-head

String#downcase == vs. String#casecmp
Rehearsal ----------------------------------------------------
String#downcase1   0.702746   0.005229   0.707975 (  0.621969)
String#downcase2   0.701429   0.001617   0.703046 (  0.691833)
String#downcase3   1.042835   0.002952   1.045787 (  0.953992)
casecmp1           0.654571   0.002239   0.656810 (  0.480158)
casecmp1-1         0.484706   0.001105   0.485811 (  0.398601)
casecmp2           0.564140   0.001579   0.565719 (  0.545332)
casecmp2-1         0.554889   0.001153   0.556042 (  0.539569)
------------------------------------------- total: 4.721190sec

                       user     system      total        real
String#downcase1   0.491199   0.001081   0.492280 (  0.493727)
String#downcase2   0.631059   0.001018   0.632077 (  0.629885)
String#downcase3   0.968867   0.002504   0.971371 (  0.976734)
casecmp1           0.364496   0.000434   0.364930 (  0.365262)
casecmp1-1         0.373140   0.000562   0.373702 (  0.374136)
casecmp2           0.487644   0.001057   0.488701 (  0.490302)
casecmp2-1         0.469868   0.001178   0.471046 (  0.472220)

ruby-1.8.7-p330

String#downcase == vs. String#casecmp
Rehearsal ----------------------------------------------------
String#downcase1   0.780000   0.000000   0.780000 (  0.783979)
String#downcase2   0.950000   0.000000   0.950000 (  0.954109)
String#downcase3   0.960000   0.000000   0.960000 (  0.960554)
casecmp1           0.440000   0.000000   0.440000 (  0.442546)
casecmp1-1         0.490000   0.000000   0.490000 (  0.487795)
casecmp2           0.530000   0.000000   0.530000 (  0.535819)
casecmp2-1         0.570000   0.000000   0.570000 (  0.574653)
------------------------------------------- total: 4.720000sec

                       user     system      total        real
String#downcase1   0.780000   0.000000   0.780000 (  0.780692)
String#downcase2   0.980000   0.010000   0.990000 (  0.982925)
String#downcase3   0.960000   0.000000   0.960000 (  0.961501)
casecmp1           0.440000   0.000000   0.440000 (  0.444528)
casecmp1-1         0.490000   0.000000   0.490000 (  0.487437)
casecmp2           0.540000   0.000000   0.540000 (  0.537686)
casecmp2-1         0.570000   0.000000   0.570000 (  0.574253)

ruby-1.9.2-p136

String#downcase == vs. String#casecmp
Rehearsal ----------------------------------------------------
String#downcase1   0.750000   0.000000   0.750000 (  0.750523)
String#downcase2   1.190000   0.000000   1.190000 (  1.193346)
String#downcase3   1.030000   0.010000   1.040000 (  1.036435)
casecmp1           0.640000   0.000000   0.640000 (  0.640327)
casecmp1-1         0.480000   0.000000   0.480000 (  0.484709)  # With all this crap running, some flukes pop out
casecmp2           0.820000   0.000000   0.820000 (  0.822223)
casecmp2-1         0.660000   0.000000   0.660000 (  0.664190)
------------------------------------------- total: 5.580000sec

                       user     system      total        real
String#downcase1   0.760000   0.000000   0.760000 (  0.759816)
String#downcase2   1.150000   0.010000   1.160000 (  1.150792)
String#downcase3   1.000000   0.000000   1.000000 (  1.005549)
casecmp1           0.650000   0.000000   0.650000 (  0.644021)
casecmp1-1         0.490000   0.000000   0.490000 (  0.494456)
casecmp2           0.820000   0.000000   0.820000 (  0.817689)
casecmp2-1         0.680000   0.000000   0.680000 (  0.685121)
=end
