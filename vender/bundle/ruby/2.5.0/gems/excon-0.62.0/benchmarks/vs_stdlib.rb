require 'rubygems' if RUBY_VERSION < '1.9'

require 'sinatra/base'
require 'tach'

require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'lib', 'excon')

module Excon
  class Server < Sinatra::Base

    def self.run
      Rack::Handler::WEBrick.run(
        Excon::Server.new,
        :Port => 9292,
        :AccessLog => [],
        :Logger => WEBrick::Log.new(nil, WEBrick::Log::ERROR)
      )
    end

    get '/data/:amount' do |amount|
      'x' * amount.to_i
    end

  end
end

def with_server(&block)
  pid = Process.fork do
    Excon::Server.run
  end
  loop do
    sleep(1)
    begin
      Excon.get('http://localhost:9292/api/foo')
      break
    rescue
    end
  end
  yield
ensure
  Process.kill(9, pid)
end

require 'net/http'
require 'open-uri'

url = 'http://localhost:9292/data/1000'

with_server do

  Tach.meter(100) do

    tach('Excon') do
      Excon.get(url).body
    end

#    tach('Excon (persistent)') do |times|
#      excon = Excon.new(url)
#      times.times do
#        excon.request(:method => 'get').body
#      end
#    end

    tach('Net::HTTP') do
      # Net::HTTP.get('localhost', '/data/1000', 9292)
      Net::HTTP.start('localhost', 9292) {|http| http.get('/data/1000').body }
    end

#    tach('Net::HTTP (persistent)') do |times|
#      Net::HTTP.start('localhost', 9292) do |http|
#        times.times do
#          http.get('/data/1000').body
#        end
#      end
#    end

#    tach('open-uri') do
#      open(url).read
#    end

  end
end
