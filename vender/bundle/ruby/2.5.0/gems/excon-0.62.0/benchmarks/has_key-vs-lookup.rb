# Copied from my benchmark_hell repo: github.com/sgonyea/benchmark_hell

require 'benchmark'

iters = 1000000
hash  = {
  'some_key' => 'some_val',
  'nil_key' => nil
}

puts 'Hash#has_key vs. Hash#[]'
Benchmark.bmbm do |x|
  x.report('Hash#has_key') do
    iters.times.each do
      hash.has_key? 'some_key'
    end
  end

  x.report('Hash#has_key (if statement)') do
    iters.times.each do
      if hash.has_key?('other_key')
        "hooray!"
      end
    end
  end

  x.report('Hash#has_key (non-existant)') do
    iters.times.each do
      hash.has_key? 'other_key'
    end
  end

  x.report('Hash#[]') do
    iters.times.each do
      hash['some_key']
    end
  end

  x.report('Hash#[] (if statement)') do
    iters.times.each do
      if hash['some_key']
        "hooray!"
      end
    end
  end

  x.report('Hash#[] (non-existant)') do
    iters.times.each do
      hash['other_key']
    end
  end

  x.report('Hash#has_key (if statement) explicit nil check') do
    iters.times.each do
      if hash.has_key?('nil_key') && !hash['nil_key'].nil?
        "hooray!"
      end
    end
  end


  x.report('Hash#has_key (if statement) implicit nil check') do
    iters.times.each do
      if hash.has_key?('nil_key') && hash['nil_key']
        "hooray!"
      end
    end
  end

  x.report('Hash#[] (if statement with nil)') do
    iters.times.each do
      if hash['nil_key']
        "hooray!"
      end
    end
  end
end

=begin

$ rvm exec bash -c 'echo $RUBY_VERSION && ruby has_key-vs-hash\[key\].rb'

jruby-1.5.6
Hash#has_key vs. Hash#[]
Rehearsal ---------------------------------------------------------------
Hash#has_key                  0.410000   0.000000   0.410000 (  0.341000)
Hash#has_key (if statement)   0.145000   0.000000   0.145000 (  0.145000)
Hash#has_key (non-existant)   0.116000   0.000000   0.116000 (  0.116000)
Hash#[]                       0.189000   0.000000   0.189000 (  0.189000)
Hash#[] (if statement)        0.176000   0.000000   0.176000 (  0.176000)
Hash#[] (non-existant)        0.302000   0.000000   0.302000 (  0.302000)
------------------------------------------------------ total: 1.338000sec

                                  user     system      total        real
Hash#has_key                  0.128000   0.000000   0.128000 (  0.128000)
Hash#has_key (if statement)   0.128000   0.000000   0.128000 (  0.128000)
Hash#has_key (non-existant)   0.153000   0.000000   0.153000 (  0.153000)
Hash#[]                       0.206000   0.000000   0.206000 (  0.206000)
Hash#[] (if statement)        0.182000   0.000000   0.182000 (  0.182000)
Hash#[] (non-existant)        0.252000   0.000000   0.252000 (  0.252000)

macruby-0.7.1
Hash#has_key vs. Hash#[]
Rehearsal ---------------------------------------------------------------
Hash#has_key                  2.530000   0.050000   2.580000 (  1.917643)
Hash#has_key (if statement)   2.590000   0.050000   2.640000 (  1.935221)
Hash#has_key (non-existant)   2.580000   0.050000   2.630000 (  1.964230)
Hash#[]                       2.240000   0.040000   2.280000 (  1.640999)
Hash#[] (if statement)        3.620000   0.070000   3.690000 (  2.530248)
Hash#[] (non-existant)        2.060000   0.040000   2.100000 (  1.473487)
----------------------------------------------------- total: 15.920000sec

                                  user     system      total        real
Hash#has_key                  2.230000   0.030000   2.260000 (  1.661843)
Hash#has_key (if statement)   2.180000   0.040000   2.220000 (  1.605644)
Hash#has_key (non-existant)   2.160000   0.040000   2.200000 (  1.582561)
Hash#[]                       2.160000   0.030000   2.190000 (  1.581448)
Hash#[] (if statement)        3.440000   0.070000   3.510000 (  2.393421)
Hash#[] (non-existant)        2.330000   0.040000   2.370000 (  1.699338)

rbx-head
Hash#has_key vs. Hash#[]
Rehearsal ---------------------------------------------------------------
Hash#has_key                  0.660584   0.004932   0.665516 (  0.508601)
Hash#has_key (if statement)   0.261708   0.000532   0.262240 (  0.263021)
Hash#has_key (non-existant)   0.265908   0.000827   0.266735 (  0.259509)
Hash#[]                       0.396607   0.001189   0.397796 (  0.372997)
Hash#[] (if statement)        0.553003   0.001589   0.554592 (  0.543859)
Hash#[] (non-existant)        0.323748   0.000884   0.324632 (  0.319055)
------------------------------------------------------ total: 2.471511sec

                                  user     system      total        real
Hash#has_key                  0.332239   0.000819   0.333058 (  0.333809)
Hash#has_key (if statement)   0.284344   0.000521   0.284865 (  0.285330)
Hash#has_key (non-existant)   0.339695   0.001301   0.340996 (  0.324259)
Hash#[]                       0.298555   0.000368   0.298923 (  0.299557)
Hash#[] (if statement)        0.392755   0.000773   0.393528 (  0.395473)
Hash#[] (non-existant)        0.277721   0.000464   0.278185 (  0.278540)

ruby-1.8.7-p330
Hash#has_key vs. Hash#[]
Rehearsal ---------------------------------------------------------------
Hash#has_key                  0.450000   0.000000   0.450000 (  0.450143)
Hash#has_key (if statement)   0.440000   0.000000   0.440000 (  0.448278)
Hash#has_key (non-existant)   0.420000   0.000000   0.420000 (  0.416959)
Hash#[]                       0.450000   0.000000   0.450000 (  0.450727)
Hash#[] (if statement)        0.550000   0.000000   0.550000 (  0.555043)
Hash#[] (non-existant)        0.530000   0.000000   0.530000 (  0.527189)
------------------------------------------------------ total: 2.840000sec

                                  user     system      total        real
Hash#has_key                  0.440000   0.000000   0.440000 (  0.447746)
Hash#has_key (if statement)   0.450000   0.000000   0.450000 (  0.450331)
Hash#has_key (non-existant)   0.420000   0.000000   0.420000 (  0.419157)
Hash#[]                       0.450000   0.000000   0.450000 (  0.454438)
Hash#[] (if statement)        0.570000   0.000000   0.570000 (  0.563948)
Hash#[] (non-existant)        0.520000   0.000000   0.520000 (  0.527866)

ruby-1.9.2-p136
Hash#has_key vs. Hash#[]
Rehearsal ---------------------------------------------------------------
Hash#has_key                  0.690000   0.000000   0.690000 (  0.691657)
Hash#has_key (if statement)   0.630000   0.000000   0.630000 (  0.638418)
Hash#has_key (non-existant)   0.640000   0.000000   0.640000 (  0.637510)
Hash#[]                       0.580000   0.000000   0.580000 (  0.584500)
Hash#[] (if statement)        0.840000   0.010000   0.850000 (  0.837541)
Hash#[] (non-existant)        0.810000   0.000000   0.810000 (  0.811598)
------------------------------------------------------ total: 4.200000sec

                                  user     system      total        real
Hash#has_key                  0.690000   0.000000   0.690000 (  0.694192)
Hash#has_key (if statement)   0.640000   0.000000   0.640000 (  0.641729)
Hash#has_key (non-existant)   0.630000   0.000000   0.630000 (  0.634470)
Hash#[]                       0.580000   0.000000   0.580000 (  0.587844)
Hash#[] (if statement)        0.830000   0.000000   0.830000 (  0.832323)
Hash#[] (non-existant)        0.790000   0.010000   0.800000 (  0.791689)
=end
