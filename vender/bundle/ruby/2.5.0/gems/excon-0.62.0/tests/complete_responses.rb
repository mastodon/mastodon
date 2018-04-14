Shindo.tests('Excon Response Validation') do
  env_init

  with_server('good') do
    tests('good responses with complete headers') do
        100.times do
          res = Excon.get('http://127.0.0.1:9292/chunked/simple')
          returns(true) { res.body == "hello world" }
          returns(true) { res.status_line ==  "HTTP/1.1 200 OK\r\n" }
          returns(true) { res.status == 200}
          returns(true) { res.reason_phrase == "OK" }
          returns(true) { res.remote_ip == "127.0.0.1" }
      end
    end
  end
 
  with_server('error') do
    tests('error responses with complete headers') do
        100.times do
          res = Excon.get('http://127.0.0.1:9292/error/not_found')
          returns(true) { res.body == "server says not found" }
          returns(true) { res.status_line ==  "HTTP/1.1 404 Not Found\r\n" }
          returns(true) { res.status == 404}
          returns(true) { res.reason_phrase == "Not Found" }
          returns(true) { res.remote_ip == "127.0.0.1" }
      end
    end
  end
  
  env_restore
end
