# viiite report --regroup bench,threads bench/pack_log_long.rb

require 'viiite'
require 'msgpack'

data_plain = { 'message' => '127.0.0.1 - - [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326 "http://www.example.com/start.html" "Mozilla/4.08 [en] (Win98; I ;Nav)"' }
data_structure = {
  'remote_host' => '127.0.0.1',
  'remote_user' => '-',
  'date' => '10/Oct/2000:13:55:36 -0700',
  'request' => 'GET /apache_pb.gif HTTP/1.0',
  'method' => 'GET',
  'path' => '/apache_pb.gif',
  'protocol' => 'HTTP/1.0',
  'status' => 200,
  'bytes' => 2326,
  'referer' => 'http://www.example.com/start.html',
  'agent' => 'Mozilla/4.08 [en] (Win98; I ;Nav)',
}

seconds = 3600 # 1 hour

Viiite.bench do |b|
  b.range_over([1, 2, 4, 8, 16], :threads) do |threads|
    b.report(:plain) do
      ths = []
      end_at = Time.now + seconds
      threads.times do
        t = Thread.new do
          packs = 0
          while Time.now < end_at
            10000.times do
              MessagePack.pack(data_plain)
            end
            packs += 10000
          end
          packs
        end
        ths.push t
      end
      sum = ths.reduce(0){|r,t| r + t.value }
      puts "MessagePack.pack, plain, #{threads} threads: #{sum} times, #{sum / seconds} times/second."
    end

    b.report(:structure) do
      ths = []
      end_at = Time.now + seconds
      threads.times do
        t = Thread.new do
          packs = 0
          while Time.now < end_at
            10000.times do
              MessagePack.pack(data_structure)
            end
            packs += 10000
          end
          packs
        end
        ths.push t
      end
      sum = ths.reduce(0){|r,t| r + t.value }
      puts "MessagePack.pack, structured, #{threads} threads: #{sum} times, #{sum / seconds} times/second."
    end
  end
end
