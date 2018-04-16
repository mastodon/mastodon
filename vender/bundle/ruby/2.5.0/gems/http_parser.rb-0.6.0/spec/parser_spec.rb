require "spec_helper"
require "json"

describe HTTP::Parser do
  before do
    @parser = HTTP::Parser.new

    @headers = nil
    @body = ""
    @started = false
    @done = false

    @parser.on_message_begin = proc{ @started = true }
    @parser.on_headers_complete = proc { |e| @headers = e }
    @parser.on_body = proc { |chunk| @body << chunk }
    @parser.on_message_complete = proc{ @done = true }
  end

  it "should have initial state" do
    @parser.headers.should be_nil

    @parser.http_version.should be_nil
    @parser.http_method.should be_nil
    @parser.status_code.should be_nil

    @parser.request_url.should be_nil

    @parser.header_value_type.should == :mixed
  end

  it "should allow us to set the header value type" do
    [:mixed, :arrays, :strings].each do |type|
      @parser.header_value_type = type
      @parser.header_value_type.should == type

      parser_tmp = HTTP::Parser.new(nil, type)
      parser_tmp.header_value_type.should == type
    end
  end

  it "should allow us to set the default header value type" do
    [:mixed, :arrays, :strings].each do |type|
      HTTP::Parser.default_header_value_type = type

      parser = HTTP::Parser.new
      parser.header_value_type.should == type
    end
  end

  it "should throw an Argument Error if header value type is invalid" do
    proc{ @parser.header_value_type = 'bob' }.should raise_error(ArgumentError)
  end

  it "should throw an Argument Error if default header value type is invalid" do
    proc{ HTTP::Parser.default_header_value_type = 'bob' }.should raise_error(ArgumentError)
  end

  it "should implement basic api" do
    @parser <<
      "GET /test?ok=1 HTTP/1.1\r\n" +
      "User-Agent: curl/7.18.0\r\n" +
      "Host: 0.0.0.0:5000\r\n" +
      "Accept: */*\r\n" +
      "Content-Length: 5\r\n" +
      "\r\n" +
      "World"

    @started.should be_true
    @done.should be_true

    @parser.http_major.should == 1
    @parser.http_minor.should == 1
    @parser.http_version.should == [1,1]
    @parser.http_method.should == 'GET'
    @parser.status_code.should be_nil

    @parser.request_url.should == '/test?ok=1'

    @parser.headers.should == @headers
    @parser.headers['User-Agent'].should == 'curl/7.18.0'
    @parser.headers['Host'].should == '0.0.0.0:5000'

    @body.should == "World"
  end

  it "should raise errors on invalid data" do
    proc{ @parser << "BLAH" }.should raise_error(HTTP::Parser::Error)
  end

  it "should abort parser via callback" do
    @parser.on_headers_complete = proc { |e| @headers = e; :stop }

    data =
      "GET / HTTP/1.0\r\n" +
      "Content-Length: 5\r\n" +
      "\r\n" +
      "World"

    bytes = @parser << data

    bytes.should == 37
    data[bytes..-1].should == 'World'

    @headers.should == {'Content-Length' => '5'}
    @body.should be_empty
    @done.should be_false
  end

  it "should reset to initial state" do
    @parser << "GET / HTTP/1.0\r\n\r\n"

    @parser.http_method.should == 'GET'
    @parser.http_version.should == [1,0]

    @parser.request_url.should == '/'

    @parser.reset!.should be_true

    @parser.http_version.should be_nil
    @parser.http_method.should be_nil
    @parser.status_code.should be_nil

    @parser.request_url.should be_nil
  end

  it "should optionally reset parser state on no-body responses" do
   @parser.reset!.should be_true

   @head, @complete = 0, 0
   @parser.on_headers_complete = proc {|h| @head += 1; :reset }
   @parser.on_message_complete = proc { @complete += 1 }
   @parser.on_body = proc {|b| fail }

   head_response = "HTTP/1.1 200 OK\r\nContent-Length:10\r\n\r\n"

   @parser << head_response
   @head.should == 1
   @complete.should == 1

   @parser << head_response
   @head.should == 2
   @complete.should == 2
  end

  it "should retain callbacks after reset" do
    @parser.reset!.should be_true

    @parser << "GET / HTTP/1.0\r\n\r\n"
    @started.should be_true
    @headers.should == {}
    @done.should be_true
  end

  it "should parse headers incrementally" do
    request =
      "GET / HTTP/1.0\r\n" +
      "Header1: value 1\r\n" +
      "Header2: value 2\r\n" +
      "\r\n"

    while chunk = request.slice!(0,2) and !chunk.empty?
      @parser << chunk
    end

    @parser.headers.should == {
      'Header1' => 'value 1',
      'Header2' => 'value 2'
    }
  end

  it "should handle multiple headers using strings" do
    @parser.header_value_type = :strings

    @parser <<
      "GET / HTTP/1.0\r\n" +
      "Set-Cookie: PREF=ID=a7d2c98; expires=Fri, 05-Apr-2013 05:00:45 GMT; path=/; domain=.bob.com\r\n" +
      "Set-Cookie: NID=46jSHxPM; path=/; domain=.bob.com; HttpOnly\r\n" +
      "\r\n"

    @parser.headers["Set-Cookie"].should == "PREF=ID=a7d2c98; expires=Fri, 05-Apr-2013 05:00:45 GMT; path=/; domain=.bob.com, NID=46jSHxPM; path=/; domain=.bob.com; HttpOnly"
  end

  it "should handle multiple headers using strings" do
    @parser.header_value_type = :arrays

    @parser <<
      "GET / HTTP/1.0\r\n" +
      "Set-Cookie: PREF=ID=a7d2c98; expires=Fri, 05-Apr-2013 05:00:45 GMT; path=/; domain=.bob.com\r\n" +
      "Set-Cookie: NID=46jSHxPM; path=/; domain=.bob.com; HttpOnly\r\n" +
      "\r\n"

    @parser.headers["Set-Cookie"].should == [
        "PREF=ID=a7d2c98; expires=Fri, 05-Apr-2013 05:00:45 GMT; path=/; domain=.bob.com",
        "NID=46jSHxPM; path=/; domain=.bob.com; HttpOnly"
    ]
  end

  it "should handle multiple headers using mixed" do
    @parser.header_value_type = :mixed

    @parser <<
      "GET / HTTP/1.0\r\n" +
      "Set-Cookie: PREF=ID=a7d2c98; expires=Fri, 05-Apr-2013 05:00:45 GMT; path=/; domain=.bob.com\r\n" +
      "Set-Cookie: NID=46jSHxPM; path=/; domain=.bob.com; HttpOnly\r\n" +
      "\r\n"

    @parser.headers["Set-Cookie"].should == [
        "PREF=ID=a7d2c98; expires=Fri, 05-Apr-2013 05:00:45 GMT; path=/; domain=.bob.com",
        "NID=46jSHxPM; path=/; domain=.bob.com; HttpOnly"
    ]
  end

  it "should handle a single cookie using mixed" do
    @parser.header_value_type = :mixed

    @parser <<
      "GET / HTTP/1.0\r\n" +
      "Set-Cookie: PREF=ID=a7d2c98; expires=Fri, 05-Apr-2013 05:00:45 GMT; path=/; domain=.bob.com\r\n" +
      "\r\n"

    @parser.headers["Set-Cookie"].should == "PREF=ID=a7d2c98; expires=Fri, 05-Apr-2013 05:00:45 GMT; path=/; domain=.bob.com"
  end

  it "should support alternative api" do
    callbacks = double('callbacks')
    callbacks.stub(:on_message_begin){ @started = true }
    callbacks.stub(:on_headers_complete){ |e| @headers = e }
    callbacks.stub(:on_body){ |chunk| @body << chunk }
    callbacks.stub(:on_message_complete){ @done = true }

    @parser = HTTP::Parser.new(callbacks)
    @parser << "GET / HTTP/1.0\r\n\r\n"

    @started.should be_true
    @headers.should == {}
    @body.should == ''
    @done.should be_true
  end

  it "should ignore extra content beyond specified length" do
    @parser <<
      "GET / HTTP/1.0\r\n" +
      "Content-Length: 5\r\n" +
      "\r\n" +
      "hello" +
      "  \n"

    @body.should == 'hello'
    @done.should be_true
  end

  it 'sets upgrade_data if available' do
    @parser <<
      "GET /demo HTTP/1.1\r\n" +
      "Connection: Upgrade\r\n" +
      "Upgrade: WebSocket\r\n\r\n" +
      "third key data"

    @parser.upgrade?.should be_true
    @parser.upgrade_data.should == 'third key data'
  end

  it 'sets upgrade_data to blank if un-available' do
    @parser <<
      "GET /demo HTTP/1.1\r\n" +
      "Connection: Upgrade\r\n" +
      "Upgrade: WebSocket\r\n\r\n"

    @parser.upgrade?.should be_true
    @parser.upgrade_data.should == ''
  end

  it 'should stop parsing headers when instructed' do
    request = "GET /websocket HTTP/1.1\r\n" +
      "host: localhost\r\n" +
      "connection: Upgrade\r\n" +
      "upgrade: websocket\r\n" +
      "sec-websocket-key: SD6/hpYbKjQ6Sown7pBbWQ==\r\n" +
      "sec-websocket-version: 13\r\n" +
      "\r\n"

    @parser.on_headers_complete = proc { |e| :stop }
    offset = (@parser << request)
    @parser.upgrade?.should be_true
    @parser.upgrade_data.should == ''
    offset.should == request.length
  end

  it "should execute on_body on requests with no content-length" do
   @parser.reset!.should be_true

   @head, @complete, @body = 0, 0, 0
   @parser.on_headers_complete = proc {|h| @head += 1 }
   @parser.on_message_complete = proc { @complete += 1 }
   @parser.on_body = proc {|b| @body += 1 }

   head_response = "HTTP/1.1 200 OK\r\n\r\nstuff"

   @parser << head_response
   @parser << ''
   @head.should == 1
   @complete.should == 1
   @body.should == 1
  end


  %w[ request response ].each do |type|
    JSON.parse(File.read(File.expand_path("../support/#{type}s.json", __FILE__))).each do |test|
      test['headers'] ||= {}
      next if !defined?(JRUBY_VERSION) and HTTP::Parser.strict? != test['strict']

      it "should parse #{type}: #{test['name']}" do
        @parser << test['raw']

        @parser.http_method.should == test['method']
        @parser.keep_alive?.should == test['should_keep_alive']

        if test.has_key?('upgrade') and test['upgrade'] != 0
          @parser.upgrade?.should be_true
          @parser.upgrade_data.should == test['upgrade']
        end

        fields = %w[
          http_major
          http_minor
        ]

        if test['type'] == 'HTTP_REQUEST'
          fields += %w[
            request_url
          ]
        else
          fields += %w[
            status_code
          ]
        end

        fields.each do |field|
          @parser.send(field).should == test[field]
        end

        @headers.size.should == test['num_headers']
        @headers.should == test['headers']

        @body.should == test['body']
        @body.size.should == test['body_size'] if test['body_size']
      end
    end
  end
end
