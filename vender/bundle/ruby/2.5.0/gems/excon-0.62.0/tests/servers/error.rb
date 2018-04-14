#!/usr/bin/env ruby

require "eventmachine"

module ErrorServer
  def receive_data(data)
    case data
    when %r{^GET /error/not_found\s}
      send_data "HTTP/1.1 404 Not Found\r\n"
      send_data "\r\n"
      send_data "server says not found"
      close_connection(true)
    end
  end
end

EM.run do
  EM.start_server("127.0.0.1", 9292, ErrorServer)
  $stderr.puts "ready"
end
