#!/usr/bin/env ruby

require "eventmachine"

module EOFServer
  def receive_data(data)
    case data
    when %r{^GET /eof\s}
      close_connection(true)
    end
  end
end

EM.run do
  EM.start_server("127.0.0.1", 9292, EOFServer)
  $stderr.puts "ready"
end
