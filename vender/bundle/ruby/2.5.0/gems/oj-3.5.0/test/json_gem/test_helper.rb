$: << File.dirname(__FILE__)
$oj_dir = File.dirname(File.dirname(File.expand_path(File.dirname(__FILE__))))
%w(lib ext).each do |dir|
  $: << File.join($oj_dir, dir)
end

require 'test/unit'
REAL_JSON_GEM = !!ENV['REAL_JSON_GEM']

if ENV['REAL_JSON_GEM']
  require 'json'
else
  require 'oj'
  Oj.mimic_JSON
end

NaN = JSON::NaN if defined?(JSON::NaN)
NaN = 0.0/0 unless defined?(NaN)
