run lambda{ |env| [200, {'Content-Type' => 'text/plain'}, [__LINE__.to_s]] }
