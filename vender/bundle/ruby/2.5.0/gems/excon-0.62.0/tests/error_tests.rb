

Shindo.tests('HTTPStatusError request/response debugging') do

  # Regression against e300458f2d9330cb265baeb8973120d08c665d9
  tests('Excon::Error knows about pertinent errors') do
    expected = [
      100, 
      101, 
      (200..206).to_a, 
      (300..307).to_a, 
      (400..417).to_a, 
      422, 
       429, 
      (500..504).to_a
    ]
    expected.flatten == Excon::Error.status_errors.keys
  end

  tests('new returns an Error').returns(true) do
    Excon::Error.new('bar').class == Excon::Error
  end

  tests('new raises errors for bad URIs').returns(true) do
    begin
      Excon.new('foo')
      false
    rescue => err
      err.to_s.include? 'foo'
    end
  end

  tests('new raises errors for bad paths').returns(true) do
    begin
      Excon.new('http://localhost', path: "foo\r\nbar: baz")
      false
    rescue => err
      err.to_s.include? "foo\r\nbar: baz"
    end
  end

  tests('can raise standard error and catch standard error').returns(true) do
    begin 
      raise Excon::Error::Client.new('foo')
    rescue Excon::Error => e
      true
    end
  end

  tests('can raise legacy errors and catch legacy errors').returns(true) do
    begin
      raise Excon::Errors::Error.new('bar')
    rescue Excon::Errors::Error => e
      true
    end
  end

  tests('can raise standard error and catch legacy errors').returns(true) do
    begin
      raise Excon::Error::NotFound.new('bar')
    rescue Excon::Errors::Error => e
      true
    end
  end

  tests('can raise with status_error() and catch with standard error').returns(true) do
    begin
      raise Excon::Error.status_error({expects: 200}, {status: 400})
    rescue Excon::Error
      true
    end
  end


  tests('can raise with  status_error() and catch with legacy error').returns(true) do
    begin
      raise Excon::Error.status_error({expects: 200}, {status: 400})
    rescue Excon::Errors::BadRequest
      true
    end
  end

  tests('can raise with legacy status_error() and catch with legacy').returns(true) do
    begin
      raise Excon::Errors.status_error({expects: 200}, {status: 400})
    rescue Excon::Errors::BadRequest
      true
    end
  end


  tests('can raise with legacy status_error() and catch with standard').returns(true) do
    begin
      raise Excon::Errors.status_error({expects: 200}, {status: 400})
    rescue Excon::Error
      true
    end
  end

  with_server('error') do

    tests('message does not include response or response info').returns(true) do
      begin
        Excon.get('http://127.0.0.1:9292/error/not_found', :expects => 200)
      rescue Excon::Errors::HTTPStatusError => err
        err.message.include?('Expected(200) <=> Actual(404 Not Found)') &&
          !err.message.include?('excon.error.request') &&
          !err.message.include?('excon.error.response')
      end
    end

    tests('message includes only request info').returns(true) do
      begin
        Excon.get('http://127.0.0.1:9292/error/not_found', :expects => 200,
                  :debug_request => true)
      rescue Excon::Errors::HTTPStatusError => err
        err.message.include?('Expected(200) <=> Actual(404 Not Found)') &&
          err.message.include?('excon.error.request') &&
          !err.message.include?('excon.error.response')
      end
    end

    tests('message includes only response info').returns(true) do
      begin
        Excon.get('http://127.0.0.1:9292/error/not_found', :expects => 200,
                  :debug_response => true)
      rescue Excon::Errors::HTTPStatusError => err
        err.message.include?('Expected(200) <=> Actual(404 Not Found)') &&
          !err.message.include?('excon.error.request') &&
          err.message.include?('excon.error.response')
      end
    end

    tests('message include request and response info').returns(true) do
      begin
        Excon.get('http://127.0.0.1:9292/error/not_found', :expects => 200,
                  :debug_request => true, :debug_response => true)
      rescue Excon::Errors::HTTPStatusError => err
        err.message.include?('Expected(200) <=> Actual(404 Not Found)') &&
          err.message.include?('excon.error.request') &&
          err.message.include?('excon.error.response')
      end
    end
  end
end
