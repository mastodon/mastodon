#!/usr/bin/env ruby

=begin
The MIT License

Copyright (c) 2010 - 2015 Slim Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
=end

#
# Original: https://github.com/slim-template/slim/blob/v3.0.6/benchmarks/run-benchmarks.rb
#
# SlimBenchmarks with following modifications:
#   1. Skipping slow engines, tilt and parsing benches.
#   2. All Ruby script and attributes are escaped for fairness.
#   3. Faml and Hamlit are added.
#

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'), File.dirname(__FILE__))

require 'slim'
require 'context'

require 'benchmark/ips'
require 'tilt'
require 'erubi'
require 'erb'
require 'haml'
require 'faml'
require 'hamlit'

class SlimBenchmarks
  def initialize(only_haml)
    @only_haml = only_haml
    @benches   = []

    @erb_code  = File.read(File.dirname(__FILE__) + '/view.erb')
    @haml_code = File.read(File.dirname(__FILE__) + '/view.haml')
    @slim_code = File.read(File.dirname(__FILE__) + '/view.slim')

    init_compiled_benches
  end

  def init_compiled_benches
    context = Context.new

    haml_ugly = Haml::Engine.new(@haml_code, format: :html5, escape_html: true)
    haml_ugly.def_method(context, :run_haml_ugly)
    context.instance_eval %{
      def run_erubi; #{Erubi::Engine.new(@erb_code).src}; end
      def run_slim_ugly; #{Slim::Engine.new.call @slim_code}; end
      def run_faml; #{Faml::Engine.new.call @haml_code}; end
      def run_hamlit; #{Hamlit::Engine.new.call @haml_code}; end
    }

    bench("erubi v#{Erubi::VERSION}")   { context.run_erubi }     unless @only_haml
    bench("slim v#{Slim::VERSION}")     { context.run_slim_ugly } unless @only_haml
    bench("haml v#{Haml::VERSION}")     { context.run_haml_ugly }
    bench("faml v#{Faml::VERSION}")     { context.run_faml }
    bench("hamlit v#{Hamlit::VERSION}") { context.run_hamlit }
  end

  def run
    Benchmark.ips do |x|
      @benches.each do |name, block|
        x.report(name.to_s, &block)
      end
      x.compare!
    end
  end

  def bench(name, &block)
    @benches.push([name, block])
  end
end

SlimBenchmarks.new(ENV['ONLY_HAML'] == '1').run
