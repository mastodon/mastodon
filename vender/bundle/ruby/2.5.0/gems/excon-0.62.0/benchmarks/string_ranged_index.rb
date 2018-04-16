# Copied from my benchmark_hell repo: github.com/sgonyea/benchmark_hell

require 'benchmark'

iters = 1000000

string = "Test String OMG"

puts 'String ranged index vs. "coordinates"'
Benchmark.bmbm do |x|
  x.report('ranged index') do
    iters.times.each do
      text = string[2..9]
    end
  end

  x.report('coordinates') do
    iters.times.each do
      text = string[2, 9]
    end
  end
end

=begin
rvm exec bash -c 'echo && echo $RUBY_VERSION && echo && ruby string_ranged_index.rb'


jruby-1.5.6

String ranged index vs. "coordinates"
Rehearsal ------------------------------------------------
ranged index   0.419000   0.000000   0.419000 (  0.372000)
coordinates    0.167000   0.000000   0.167000 (  0.167000)
--------------------------------------- total: 0.586000sec

                   user     system      total        real
ranged index   0.158000   0.000000   0.158000 (  0.159000)
coordinates    0.125000   0.000000   0.125000 (  0.125000)

macruby-0.7.1

String ranged index vs. "coordinates"
Rehearsal ------------------------------------------------
ranged index   1.490000   0.030000   1.520000 (  1.061326)
coordinates    1.410000   0.030000   1.440000 (  0.973640)
--------------------------------------- total: 2.960000sec

                   user     system      total        real
ranged index   1.520000   0.030000   1.550000 (  1.081424)
coordinates    1.480000   0.030000   1.510000 (  1.029214)

rbx-head

String ranged index vs. "coordinates"
Rehearsal ------------------------------------------------
ranged index   1.333304   0.009398   1.342702 (  1.229629)
coordinates    0.306087   0.000603   0.306690 (  0.303538)
--------------------------------------- total: 1.649392sec

                   user     system      total        real
ranged index   0.923626   0.001597   0.925223 (  0.927411)
coordinates    0.298910   0.000533   0.299443 (  0.300255)

ruby-1.8.7-p330

String ranged index vs. "coordinates"
Rehearsal ------------------------------------------------
ranged index   0.730000   0.000000   0.730000 (  0.738612)
coordinates    0.660000   0.000000   0.660000 (  0.660689)
--------------------------------------- total: 1.390000sec

                   user     system      total        real
ranged index   0.750000   0.000000   0.750000 (  0.746172)
coordinates    0.640000   0.000000   0.640000 (  0.640687)

ruby-1.9.2-p136

String ranged index vs. "coordinates"
Rehearsal ------------------------------------------------
ranged index   0.670000   0.000000   0.670000 (  0.679046)
coordinates    0.620000   0.000000   0.620000 (  0.622257)
--------------------------------------- total: 1.290000sec

                   user     system      total        real
ranged index   0.680000   0.000000   0.680000 (  0.686510)
coordinates    0.620000   0.000000   0.620000 (  0.624269)
=end
