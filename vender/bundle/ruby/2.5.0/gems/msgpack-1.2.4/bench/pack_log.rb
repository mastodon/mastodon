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

Viiite.bench do |b|
  b.range_over([10_000, 100_000, 1000_000], :runs) do |runs|
    b.report(:plain) do
      runs.times do
        MessagePack.pack(data_plain)
      end
    end

    b.report(:structure) do
      runs.times do
        MessagePack.pack(data_structure)
      end
    end
  end
end
