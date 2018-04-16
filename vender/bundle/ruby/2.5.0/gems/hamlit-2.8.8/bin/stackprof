#!/usr/bin/env ruby

require 'bundler/setup'
require 'hamlit'
require 'stackprof'

def open_flamegraph(report)
  temp = `mktemp /tmp/stackflame-XXXXXXXX`.strip
  data_path = "#{temp}.js"
  system("mv #{temp} #{data_path}")

  File.open(data_path, 'w') do |f|
    report.print_flamegraph(f)
  end

  viewer_path = File.join(`bundle show stackprof`.strip, 'lib/stackprof/flamegraph/viewer.html')
  url = "file://#{viewer_path}?data=#{data_path}"
  system(%Q[osascript -e 'open location "#{url}"'])
end

haml = File.read(ARGV.first)
StackProf.start(mode: :wall, interval: 1, raw: false)
Hamlit::Engine.new.call(haml)
StackProf.stop

report = StackProf::Report.new(StackProf.results)
report.print_text(false)
