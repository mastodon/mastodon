#\ -d -p 2929 --env test
run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['OK']] }
