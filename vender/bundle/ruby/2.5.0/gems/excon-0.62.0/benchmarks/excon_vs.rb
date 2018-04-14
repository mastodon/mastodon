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

require 'em-http-request'
require 'httparty'
require 'net/http'
require 'open-uri'
require 'rest_client'
require 'tach'
require 'typhoeus'

size = 10_000
path = '/data/' << size.to_s
url = 'http://localhost:9292' << path

times = 1_000

with_server do

  Tach.meter(times) do

    tach('curb (persistent)') do |n|
      curb = Curl::Easy.new

      n.times do
        curb.url = url
        curb.http_get
        curb.body_str
      end
    end

    tach('em-http-request') do |n|
      EventMachine.run {
        count = 0

        n.times do
          http = EventMachine::HttpRequest.new(url).get

          http.callback {
            http.response
            count += 1
            EM.stop if count == n
          }

          http.errback {
            http.response
            count += 1
            EM.stop if count == n
          }
        end
      }
    end

    tach('Excon') do
      Excon.get(url).body
    end

    excon = Excon.new(url)
    tach('Excon (persistent)') do
      excon.request(:method => 'get').body
    end

    tach('HTTParty') do
      HTTParty.get(url).body
    end

    tach('Net::HTTP') do
      # Net::HTTP.get('localhost', path, 9292)
      Net::HTTP.start('localhost', 9292) {|http| http.get(path).body }
    end

    Net::HTTP.start('localhost', 9292) do |http|
      tach('Net::HTTP (persistent)') do
        http.get(path).body
      end
    end

    tach('open-uri') do
      open(url).read
    end

    tach('RestClient') do
      RestClient.get(url)
    end

    streamly = StreamlyFFI::Connection.new
    tach('StreamlyFFI (persistent)') do
      streamly.get(url)
    end

    tach('Typhoeus') do
      Typhoeus::Request.get(url).body
    end

  end
end

# +--------------------------+----------+
# | tach                     | total    |
# +--------------------------+----------+
# | Excon (persistent)       | 1.529095 |
# +--------------------------+----------+
# | curb (persistent)        | 1.740387 |
# +--------------------------+----------+
# | Typhoeus                 | 1.876236 |
# +--------------------------+----------+
# | Excon                    | 2.001858 |
# +--------------------------+----------+
# | StreamlyFFI (persistent) | 2.200701 |
# +--------------------------+----------+
# | Net::HTTP                | 2.395704 |
# +--------------------------+----------+
# | Net::HTTP (persistent)   | 2.418099 |
# +--------------------------+----------+
# | HTTParty                 | 2.659317 |
# +--------------------------+----------+
# | RestClient               | 2.958159 |
# +--------------------------+----------+
# | open-uri                 | 2.987051 |
# +--------------------------+----------+
# | em-http-request          | 4.123798 |
# +--------------------------+----------+
