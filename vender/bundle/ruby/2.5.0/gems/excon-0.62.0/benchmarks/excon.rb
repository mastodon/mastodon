require 'rubygems' if RUBY_VERSION < '1.9'
require 'bundler'

Bundler.require(:default)
Bundler.require(:benchmark)

require 'sinatra/base'

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

require 'tach'

size = 10_000
path = '/data/' << size.to_s
url = 'http://localhost:9292' << path

times = 1_000

with_server do

  Tach.meter(times) do

    tach('Excon') do
      Excon.get(url).body
    end

    excon = Excon.new(url)
    tach('Excon (persistent)') do
      excon.request(:method => 'get').body
    end

  end
end
