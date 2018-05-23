#!/usr/bin/env ruby

require "eventmachine"

module BadServer
  def receive_data(data)
    case data
    when %r{^GET /eof/no_content_length_and_no_chunking\s}
      send_data "HTTP/1.1 200 OK\r\n"
      send_data "\r\n"
      send_data "hello"
      close_connection(true)
    end
  end
end

EM.run do
  EM.start_server("127.0.0.1", 9292, BadServer)
  $stderr.puts "ready"
end
