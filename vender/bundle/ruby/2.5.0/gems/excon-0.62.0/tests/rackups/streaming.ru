use Rack::ContentType, "text/plain"

app = lambda do |env|
  # streamed pieces to be sent
  pieces = %w{Hello streamy world}

  response_headers = {}

  # set a fixed content length in the header if requested
  if env['REQUEST_PATH'] == '/streamed/fixed_length'
    response_headers['Content-Length'] = pieces.join.length.to_s
  end

  response_headers["rack.hijack"] = lambda do |io|
    # Write directly to IO of the response
    begin
      # return the response in pieces
      pieces.each do |x|
        sleep(0.1)
        io.write(x)
        io.flush
      end
    ensure
      io.close
    end
  end
  [200, response_headers, nil]
end

run app
