# Copied from my benchmark_hell repo: github.com/sgonyea/benchmark_hell

require 'benchmark'

iters = 1000000

def do_explicit(&block)
  var = "hello"
  block.call(var)
end

def do_implicit
  var = "hello"
  yield(var)
end

puts 'explicit block vs implicit'
Benchmark.bmbm do |x|
  x.report('explicit') do
    iters.times.each do
      do_explicit {|var|
        var << "goodbye"
      }
    end
  end

  x.report('implicit') do
    iters.times.each do
      do_implicit {|var|
        var << "goodbye"
      }
    end
  end
end

=begin
rvm exec bash -c 'echo && echo $RUBY_VERSION && echo && ruby implicit_block-vs-explicit_block.rb'

jruby-1.5.6

explicit block vs implicit
Rehearsal --------------------------------------------
explicit   1.163000   0.000000   1.163000 (  1.106000)
implicit   0.499000   0.000000   0.499000 (  0.499000)
----------------------------------- total: 1.662000sec

               user     system      total        real
explicit   0.730000   0.000000   0.730000 (  0.730000)
implicit   0.453000   0.000000   0.453000 (  0.453000)

macruby-0.7.1

explicit block vs implicit
Rehearsal --------------------------------------------
explicit   5.070000   0.130000   5.200000 (  3.546388)
implicit   3.140000   0.050000   3.190000 (  2.255986)
----------------------------------- total: 8.390000sec

               user     system      total        real
explicit   5.340000   0.140000   5.480000 (  3.774963)
implicit   3.170000   0.060000   3.230000 (  2.279951)

rbx-head

explicit block vs implicit
Rehearsal --------------------------------------------
explicit   1.270136   0.006507   1.276643 (  1.181588)
implicit   0.839831   0.002203   0.842034 (  0.820849)
----------------------------------- total: 2.118677sec

               user     system      total        real
explicit   0.960593   0.001526   0.962119 (  0.966404)
implicit   0.700361   0.001126   0.701487 (  0.703591)

ruby-1.8.7-p330

explicit block vs implicit
Rehearsal --------------------------------------------
explicit   3.970000   0.000000   3.970000 (  3.985157)
implicit   1.560000   0.000000   1.560000 (  1.567599)
----------------------------------- total: 5.530000sec

               user     system      total        real
explicit   3.990000   0.010000   4.000000 (  4.002637)
implicit   1.560000   0.000000   1.560000 (  1.560901)

ruby-1.9.2-p136

explicit block vs implicit
Rehearsal --------------------------------------------
explicit   2.620000   0.010000   2.630000 (  2.633762)
implicit   1.080000   0.000000   1.080000 (  1.076809)
----------------------------------- total: 3.710000sec

               user     system      total        real
explicit   2.630000   0.010000   2.640000 (  2.637658)
implicit   1.070000   0.000000   1.070000 (  1.073589)
=end
