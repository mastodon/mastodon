require 'rubygems'
require 'stringio'
require 'tach'

def all_match_socket
  io = StringIO.new
  io << "Connection: close\n"
  io << "Content-Length: 000\n"
  io << "Content-Type: text/html\n"
  io << "Date: Xxx, 00 Xxx 0000 00:00:00 GMT\n"
  io << "Server: xxx\n"
  io << "Transfer-Encoding: chunked\n"
  io << "\n\n"
  io.rewind
  io
end

Formatador.display_line('all_match')
Formatador.indent do
  Tach.meter(10_000) do
    tach('compare on read') do
      socket, headers = all_match_socket, {}
      until ((data = socket.readline).chop!).empty?
        key, value = data.split(': ')
        headers[key] = value
        (key.casecmp('Transfer-Encoding') == 0) && (value.casecmp('chunked') == 0)
        (key.casecmp('Connection') == 0) && (value.casecmp('close') == 0)
        (key.casecmp('Content-Length') == 0)
      end
    end

    tach('original') do
      socket, headers = all_match_socket, {}
      until ((data = socket.readline).chop!).empty?
        key, value = data.split(': ')
        headers[key] = value
      end
      headers.has_key?('Transfer-Encoding') && headers['Transfer-Encoding'].casecmp('chunked') == 0
      headers.has_key?('Connection') && headers['Connection'].casecmp('close') == 0
      headers.has_key?('Content-Length')
    end
  end
end

def none_match_socket
  io = StringIO.new
  io << "Cache-Control: max-age=0\n"
  io << "Content-Type: text/html\n"
  io << "Date: Xxx, 00 Xxx 0000 00:00:00 GMT\n"
  io << "Expires: Xxx, 00 Xxx 0000 00:00:00 GMT\n"
  io << "Last-Modified: Xxx, 00 Xxx 0000 00:00:00 GMT\n"
  io << "Server: xxx\n"
  io << "\n\n"
  io.rewind
  io
end

Formatador.display_line('none_match')
Formatador.indent do
  Tach.meter(10_000) do
    tach('compare on read') do
      socket, headers = none_match_socket, {}
      until ((data = socket.readline).chop!).empty?
        key, value = data.split(': ')
        headers[key] = value
        (key.casecmp('Transfer-Encoding') == 0) && (value.casecmp('chunked') == 0)
        (key.casecmp('Connection') == 0) && (value.casecmp('close') == 0)
        (key.casecmp('Content-Length') == 0)
      end
    end

    tach('original') do
      socket, headers = none_match_socket, {}
      until ((data = socket.readline).chop!).empty?
        key, value = data.split(': ')
        headers[key] = value
      end
      headers.has_key?('Transfer-Encoding') && headers['Transfer-Encoding'].casecmp('chunked') == 0
      headers.has_key?('Connection') && headers['Connection'].casecmp('close') == 0
      headers.has_key?('Content-Length')
    end
  end
end