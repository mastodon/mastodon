$:.unshift(File.join("../../lib", __FILE__))
$:.unshift File.dirname(__FILE__)

require "bundler/setup"
require 'rspec'
require 'rdf'
require 'rdf/isomorphic'
require 'rdf/nquads'
require 'rdf/turtle'
require 'rdf/trig'
require 'rdf/vocab'
require 'rdf/spec'
require 'rdf/spec/matchers'
require 'yaml'
begin
  require 'simplecov'
  require 'coveralls' unless ENV['NOCOVERALLS']
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    (Coveralls::SimpleCov::Formatter unless ENV['NOCOVERALLS'])
  ])
  SimpleCov.start do
    add_filter "/spec/"
  end
rescue LoadError
end

require 'json/ld'

JSON_STATE = JSON::State.new(
  indent:       "  ",
  space:        " ",
  space_before: "",
  object_nl:    "\n",
  array_nl:     "\n"
)

# Create and maintain a cache of downloaded URIs
URI_CACHE = File.expand_path(File.join(File.dirname(__FILE__), "uri-cache"))
Dir.mkdir(URI_CACHE) unless File.directory?(URI_CACHE)
# Cache client requests

::RSpec.configure do |c|
  c.filter_run focus: true
  c.run_all_when_everything_filtered = true
  c.include(RDF::Spec::Matchers)
end

# Heuristically detect the input stream
def detect_format(stream)
  # Got to look into the file to see
  if stream.respond_to?(:rewind) && stream.respond_to?(:read)
    stream.rewind
    string = stream.read(1000)
    stream.rewind
  else
    string = stream.to_s
  end
  case string
  when /<html/i           then RDF::RDFa::Reader
  when /\{\s*\"@\"/i      then JSON::LD::Reader
  else                         RDF::Turtle::Reader
  end
end

