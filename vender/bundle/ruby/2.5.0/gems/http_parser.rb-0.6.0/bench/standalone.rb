#!/usr/bin/env ruby
$:.unshift File.dirname(__FILE__) + "/../lib"
require "rubygems"
require "http/parser"
require "benchmark/ips"

request = <<-REQUEST
GET / HTTP/1.1
Host: www.example.com
Connection: keep-alive
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.78 S
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Encoding: gzip,deflate,sdch
Accept-Language: en-US,en;q=0.8
Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.3

REQUEST
request.gsub!(/\n/m, "\r\n")

Benchmark.ips do |ips|
  ips.report("instance") { Http::Parser.new }
  ips.report("parsing")  { Http::Parser.new << request }
end
