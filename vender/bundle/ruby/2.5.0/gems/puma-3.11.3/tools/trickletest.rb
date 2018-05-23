require 'socket'
require 'stringio'

def do_test(st, chunk)
  s = TCPSocket.new('127.0.0.1',ARGV[0].to_i);
  req = StringIO.new(st)
  nout = 0
  randstop = rand(st.length / 10)
  STDERR.puts "stopping after: #{randstop}"

  begin
    while data = req.read(chunk)
      nout += s.write(data)
      s.flush
      sleep 0.1
      if nout > randstop
        STDERR.puts "BANG! after #{nout} bytes."
        break
      end
    end
  rescue Object => e
    STDERR.puts "ERROR: #{e}"
  ensure
    s.close
  end
end

content = "-" * (1024 * 240)
st = "GET / HTTP/1.1\r\nHost: www.zedshaw.com\r\nContent-Type: text/plain\r\nContent-Length: #{content.length}\r\n\r\n#{content}"

puts "length: #{content.length}"

threads = []
ARGV[1].to_i.times do
  t = Thread.new do
    size = 100
    puts ">>>> #{size} sized chunks"
    do_test(st, size)
  end

  t.abort_on_exception = true
  threads << t
end

threads.each {|t|  t.join}
