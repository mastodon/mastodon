require 'test_helper'

class Elasticsearch::Transport::Transport::HTTP::FaradayTest < Test::Unit::TestCase
  include Elasticsearch::Transport::Transport::HTTP

  context "Faraday transport" do
    setup do
      @transport = Faraday.new :hosts => [ { :host => 'foobar', :port => 1234 } ]
    end

    should "implement host_unreachable_exceptions" do
      assert_instance_of Array, @transport.host_unreachable_exceptions
    end

    should "implement __build_connections" do
      assert_equal 1, @transport.hosts.size
      assert_equal 1, @transport.connections.size

      assert_instance_of ::Faraday::Connection, @transport.connections.first.connection
      assert_equal 'http://foobar:1234/',       @transport.connections.first.connection.url_prefix.to_s
    end

    should "perform the request" do
      @transport.connections.first.connection.expects(:run_request).returns(stub_everything)
      @transport.perform_request 'GET', '/'
    end

    should "return a Response" do
      @transport.connections.first.connection.expects(:run_request).returns(stub_everything)
      response = @transport.perform_request 'GET', '/'
      assert_instance_of Elasticsearch::Transport::Transport::Response, response
    end

    should "properly prepare the request" do
      @transport.connections.first.connection.expects(:run_request).with do |method, url, body, headers|
        assert_equal :post, method
        assert_equal '{"foo":"bar"}', body
        assert_nil   headers['Accept']
        true
      end.returns(stub_everything)

      @transport.perform_request 'POST', '/', {}, {:foo => 'bar'}
    end

    should "properly prepare the request with custom headers" do
      @transport.connections.first.connection.expects(:run_request).with do |method, url, body, headers|
        assert_equal :post, method
        assert_equal '{"foo":"bar"}', body
        assert_nil   headers['Accept']
        assert_equal "application/x-ndjson", headers['Content-Type']
        true
      end.returns(stub_everything)

      @transport.perform_request 'POST', '/', {}, {:foo => 'bar'}, {"Content-Type" => "application/x-ndjson"}
    end

    should "properly pass the Content-Type header option" do
      transport = Faraday.new :hosts => [ { :host => 'foobar', :port => 1234 } ], :options => { :transport_options => { :headers => { 'Content-Type' => 'foo/bar' } } }

      transport.connections.first.connection.expects(:run_request).with do |method, url, body, headers|
        assert_equal 'foo/bar', headers['Content-Type']
        true
      end.returns(stub_everything)

      transport.perform_request 'GET', '/'
    end

    should "serialize the request body" do
      @transport.connections.first.connection.expects(:run_request).returns(stub_everything)
      @transport.serializer.expects(:dump)
      @transport.perform_request 'POST', '/', {}, {:foo => 'bar'}
    end

    should "not serialize a String request body" do
      @transport.connections.first.connection.expects(:run_request).returns(stub_everything)
      @transport.serializer.expects(:dump).never
      @transport.perform_request 'POST', '/', {}, '{"foo":"bar"}'
    end

    should "pass the selector_class options to collection" do
      @transport = Faraday.new :hosts => [ { :host => 'foobar', :port => 1234 } ],
                               :options => { :selector_class => Elasticsearch::Transport::Transport::Connections::Selector::Random }
      assert_instance_of Elasticsearch::Transport::Transport::Connections::Selector::Random,
                         @transport.connections.selector
    end

    should "pass the selector option to collection" do
      @transport = Faraday.new :hosts => [ { :host => 'foobar', :port => 1234 } ],
                               :options => { :selector => Elasticsearch::Transport::Transport::Connections::Selector::Random.new }
      assert_instance_of Elasticsearch::Transport::Transport::Connections::Selector::Random,
                         @transport.connections.selector
    end

    should "pass a configuration block to the Faraday constructor" do
      config_block = lambda do |f|
        f.response :logger
        f.path_prefix = '/moo'
      end

      transport = Faraday.new :hosts => [ { :host => 'foobar', :port => 1234 } ], &config_block

      handlers = transport.connections.first.connection.builder.handlers

      assert_equal 1, handlers.size
      assert handlers.include?(::Faraday::Response::Logger), "#{handlers.inspect} does not include <::Faraday::Adapter::Logger>"

      assert_equal '/moo',                   transport.connections.first.connection.path_prefix
      assert_equal 'http://foobar:1234/moo', transport.connections.first.connection.url_prefix.to_s
    end

    should "pass transport_options to the Faraday constructor" do
      transport = Faraday.new :hosts => [ { :host => 'foobar', :port => 1234 } ],
                              :options => { :transport_options => {
                                              :request => { :open_timeout => 1 },
                                              :headers => { :foo_bar => 'bar'  },
                                              :ssl     => { :verify => false }
                                            }
                                          }

      assert_equal 1,     transport.connections.first.connection.options.open_timeout
      assert_equal 'bar', transport.connections.first.connection.headers['Foo-Bar']
      assert_equal false, transport.connections.first.connection.ssl.verify?
    end

    should "merge in parameters defined in the Faraday connection parameters" do
      transport = Faraday.new :hosts => [ { :host => 'foobar', :port => 1234 } ],
                              :options => { :transport_options => {
                                              :params => { :format => 'yaml' }
                                            }
                                          }
      # transport.logger = Logger.new(STDERR)

      transport.connections.first.connection.expects(:run_request).
        with do |method, url, params, body|
          assert_match /\?format=yaml/, url
          true
        end.
        returns(stub_everything)

      transport.perform_request 'GET', ''
    end

    should "not overwrite request parameters with the Faraday connection parameters" do
      transport = Faraday.new :hosts => [ { :host => 'foobar', :port => 1234 } ],
                              :options => { :transport_options => {
                                              :params => { :format => 'yaml' }
                                            }
                                          }
      # transport.logger = Logger.new(STDERR)

      transport.connections.first.connection.expects(:run_request).
        with do |method, url, params, body|
          assert_match /\?format=json/, url
          true
        end.
        returns(stub_everything)

      transport.perform_request 'GET', '', { :format => 'json' }
    end

    should "set the credentials if passed" do
      transport = Faraday.new :hosts => [ { :host => 'foobar', :port => 1234, :user => 'foo', :password => 'bar' } ]
      assert_equal 'Basic Zm9vOmJhcg==', transport.connections.first.connection.headers['Authorization']
    end

    should "set the credentials if they exist in options" do
      transport = Faraday.new :hosts => [ { :host => 'foobar', :port => 1234 } ],
                              :options => { :user => 'foo', :password => 'bar' }
      assert_equal 'Basic Zm9vOmJhcg==', transport.connections.first.connection.headers['Authorization']
    end

    should "override options credentials if passed explicitly" do
      transport = Faraday.new :hosts => [ { :host => 'foobar', :port => 1234, :user => 'foo', :password => 'bar' },
                                          { :host => 'foobar2', :port => 1234 } ],
                              :options => { :user => 'foo2', :password => 'bar2' }
      assert_equal 'Basic Zm9vOmJhcg==', transport.connections.first.connection.headers['Authorization']
      assert_equal 'Basic Zm9vMjpiYXIy', transport.connections[1].connection.headers['Authorization']
    end

    should "set connection scheme to https if passed" do
      transport = Faraday.new :hosts => [ { :host => 'foobar', :port => 1234, :scheme => 'https' } ]

      assert_instance_of ::Faraday::Connection, transport.connections.first.connection
      assert_equal 'https://foobar:1234/',       transport.connections.first.connection.url_prefix.to_s
    end

    should "set connection scheme to https if it exist in options" do
      transport = Faraday.new :hosts => [ { :host => 'foobar', :port => 1234} ],
                              :options => { :scheme => 'https' }

      assert_instance_of ::Faraday::Connection, transport.connections.first.connection
      assert_equal 'https://foobar:1234/',       transport.connections.first.connection.url_prefix.to_s
    end

    should "override options scheme if passed explicitly" do
      transport = Faraday.new :hosts => [ { :host => 'foobar', :port => 1234, :scheme => 'http'} ],
                              :options => { :scheme => 'https' }

      assert_instance_of ::Faraday::Connection, transport.connections.first.connection
      assert_equal 'http://foobar:1234/',       transport.connections.first.connection.url_prefix.to_s
    end

    should "use global http configuration" do
      transport = Faraday.new :hosts => [ { :host => 'foobar', :port => 1234 } ],
                              :options => { :http => { :scheme => 'https', :user => 'U', :password => 'P' } }

      assert_equal 'https://U:P@foobar:1234/', transport.connections.first.full_url('')
    end
  end

end
