$:.unshift File.dirname(__FILE__) + "/../lib"
require "rubygems"
require "thin_parser"
require "http_parser"
require "benchmark"
require "stringio"

data = "POST /postit HTTP/1.1\r\n" +
       "Host: localhost:3000\r\n" +
       "User-Agent: Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1.9) Gecko/20071025 Firefox/2.0.0.9\r\n" +
       "Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5\r\n" +
       "Accept-Language: en-us,en;q=0.5\r\n" +
       "Accept-Encoding: gzip,deflate\r\n" +
       "Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7\r\n" +
       "Keep-Alive: 300\r\n" +
       "Connection: keep-alive\r\n" +
       "Content-Type: text/html\r\n" +
       "Content-Length: 37\r\n" +
       "\r\n" +
       "name=marc&email=macournoyer@gmail.com"

def thin(data)
  env = {"rack.input" => StringIO.new}
  Thin::HttpParser.new.execute(env, data, 0)
  env
end

def http_parser(data)
  body = StringIO.new
  env = nil

  parser = HTTP::RequestParser.new
  parser.on_headers_complete = proc { |e| env = e }
  parser.on_body = proc { |c| body << c }
  parser << data

  env["rack-input"] = body
  env
end

# p thin(data)
# p http_parser(data)

TESTS = 30_000
Benchmark.bmbm do |results|
  results.report("thin:") { TESTS.times { thin data } }
  results.report("http-parser:") { TESTS.times { http_parser data } }
end

# On my MBP core duo 2.2Ghz
# Rehearsal ------------------------------------------------
# thin:          1.470000   0.000000   1.470000 (  1.474737)
# http-parser:   1.270000   0.020000   1.290000 (  1.292758)
# --------------------------------------- total: 2.760000sec
#
#                    user     system      total        real
# thin:          1.150000   0.030000   1.180000 (  1.173767)
# http-parser:   1.250000   0.010000   1.260000 (  1.263796)
