require 'test_helper'

class Elasticsearch::Transport::ClientTest < Test::Unit::TestCase

  class DummyTransport
    def initialize(*); end
  end

  context "Client" do
    setup do
      Elasticsearch::Transport::Client::DEFAULT_TRANSPORT_CLASS.any_instance.stubs(:__build_connections)
      @client = Elasticsearch::Transport::Client.new
    end

    should "be aliased as Elasticsearch::Client" do
      assert_nothing_raised do
        assert_instance_of(Elasticsearch::Transport::Client, Elasticsearch::Client.new)
      end
    end

    should "have default transport" do
      assert_instance_of Elasticsearch::Transport::Client::DEFAULT_TRANSPORT_CLASS, @client.transport
    end

    should "instantiate custom transport class" do
      client = Elasticsearch::Transport::Client.new :transport_class => DummyTransport
      assert_instance_of DummyTransport, client.transport
    end

    should "take custom transport instance" do
      client = Elasticsearch::Transport::Client.new :transport => DummyTransport.new
      assert_instance_of DummyTransport, client.transport
    end

    should "delegate performing requests to transport" do
      assert_respond_to @client, :perform_request
      @client.transport.expects(:perform_request)
      @client.perform_request 'GET', '/'
    end

    should "send GET request as POST with the send_get_body_as option" do
      transport = DummyTransport.new
      client = Elasticsearch::Transport::Client.new :transport => transport, :send_get_body_as => 'POST'
      transport.expects(:perform_request).with 'POST', '/', {}, '{"foo":"bar"}', nil
      client.perform_request 'GET', '/', {}, '{"foo":"bar"}'
    end

    should "call perform_request with custom headers" do
      transport = DummyTransport.new
      client = Elasticsearch::Transport::Client.new :transport => transport, :send_get_body_as => 'POST'
      transport.expects(:perform_request).with 'POST', '/', {}, '{"foo":"bar"}', '{"Content-Type":"application/x-ndjson"}'
      client.perform_request 'POST', '/', {}, '{"foo":"bar"}', '{"Content-Type":"application/x-ndjson"}'
    end

    should "have default logger for transport" do
      client = Elasticsearch::Transport::Client.new :log => true
      assert_respond_to client.transport.logger, :info
    end

    should "have default tracer for transport" do
      client = Elasticsearch::Transport::Client.new :trace => true
      assert_respond_to client.transport.tracer, :info
    end

    should "initialize the default transport class" do
      Elasticsearch::Transport::Client::DEFAULT_TRANSPORT_CLASS.any_instance.
        unstub(:__build_connections)

      client = Elasticsearch::Client.new
      assert_match /Faraday/, client.transport.connections.first.connection.headers['User-Agent']
    end

    should "pass options to the transport" do
      client = Elasticsearch::Transport::Client.new :transport_options => { :foo => 'bar' }
      assert_equal 'bar', client.transport.options[:transport_options][:foo]
    end

    should "merge request_timeout to the transport options" do
      client = Elasticsearch::Transport::Client.new :request_timeout => 120
      assert_equal 120, client.transport.options[:transport_options][:request][:timeout]
    end

    should "set the 'Content-Type' header to 'application/json' by default" do
      client = Elasticsearch::Transport::Client.new
      assert_equal 'application/json', client.transport.options[:transport_options][:headers]['Content-Type']
    end

    context "when passed hosts" do
      should "have localhost by default" do
        c = Elasticsearch::Transport::Client.new
        assert_equal 'localhost', c.transport.hosts.first[:host]
      end

      should "take :hosts, :host, :url or :urls" do
        c1 = Elasticsearch::Transport::Client.new :hosts => ['foobar']
        c2 = Elasticsearch::Transport::Client.new :host  => 'foobar'
        c3 = Elasticsearch::Transport::Client.new :url   => 'foobar'
        c4 = Elasticsearch::Transport::Client.new :urls  => 'foo,bar'

        assert_equal 'foobar', c1.transport.hosts[0][:host]
        assert_equal 'foobar', c2.transport.hosts[0][:host]
        assert_equal 'foobar', c3.transport.hosts[0][:host]
        assert_equal 'foo',    c4.transport.hosts[0][:host]
        assert_equal 'bar',    c4.transport.hosts[1][:host]
      end

    end

    context "when the URL is set in the environment variable" do
      setup    { ENV['ELASTICSEARCH_URL'] = 'foobar' }
      teardown { ENV.delete('ELASTICSEARCH_URL')     }

      should "use a single host" do
        c = Elasticsearch::Transport::Client.new

        assert_equal 1,     c.transport.hosts.size
        assert_equal 'foobar', c.transport.hosts.first[:host]
      end

      should "use multiple hosts" do
        ENV['ELASTICSEARCH_URL'] = 'foo, bar'
        c = Elasticsearch::Transport::Client.new

        assert_equal 2,     c.transport.hosts.size
        assert_equal 'foo', c.transport.hosts[0][:host]
        assert_equal 'bar', c.transport.hosts[1][:host]
      end
    end

    context "extracting hosts" do
      should "extract from string" do
        hosts = @client.__extract_hosts 'myhost'

        assert_equal 'myhost', hosts[0][:host]
        assert_nil             hosts[0][:port]
      end

      should "extract from hash" do
        hosts = @client.__extract_hosts( { :host => 'myhost', :scheme => 'https' } )
        assert_equal 'myhost', hosts[0][:host]
        assert_equal 'https',  hosts[0][:scheme]
        assert_nil             hosts[0][:port]
      end

      should "extract from hash with a port passed as a string" do
        hosts = @client.__extract_hosts( { :host => 'myhost', :scheme => 'https', :port => '443' } )
        assert_equal 443, hosts[0][:port]
      end

      should "extract from hash with a port passed as an integer" do
        hosts = @client.__extract_hosts( { :host => 'myhost', :scheme => 'https', :port => 443 } )
        assert_equal 443, hosts[0][:port]
      end

      should "extract from Hashie::Mash" do
        hosts = @client.__extract_hosts( Hashie::Mash.new(:host => 'myhost', :scheme => 'https') )
        assert_equal 'myhost', hosts[0][:host]
        assert_equal 'https',  hosts[0][:scheme]
      end

      should "extract from array" do
        hosts = @client.__extract_hosts ['myhost']

        assert_equal 'myhost', hosts[0][:host]
      end

      should "extract from array with multiple hosts" do
        hosts = @client.__extract_hosts ['host1', 'host2']

        assert_equal 'host1', hosts[0][:host]
        assert_equal 'host2', hosts[1][:host]
      end

      should "extract from array with ports" do
        hosts = @client.__extract_hosts ['host1:1000', 'host2:2000']

        assert_equal 2, hosts.size

        assert_equal 'host1', hosts[0][:host]
        assert_equal 1000,    hosts[0][:port]

        assert_equal 'host2', hosts[1][:host]
        assert_equal 2000,    hosts[1][:port]
      end

      should "extract path" do
        hosts = @client.__extract_hosts 'https://myhost:8080/api'

        assert_equal '/api',  hosts[0][:path]
      end

      should "extract scheme (protocol)" do
        hosts = @client.__extract_hosts 'https://myhost:8080'

        assert_equal 'https',  hosts[0][:scheme]
        assert_equal 'myhost', hosts[0][:host]
        assert_equal 8080,     hosts[0][:port]
      end

      should "extract credentials" do
        hosts = @client.__extract_hosts 'http://USERNAME:PASSWORD@myhost:8080'

        assert_equal 'http',     hosts[0][:scheme]
        assert_equal 'USERNAME', hosts[0][:user]
        assert_equal 'PASSWORD', hosts[0][:password]
        assert_equal 'myhost',   hosts[0][:host]
        assert_equal 8080,       hosts[0][:port]
      end

      should "pass hashes over" do
        hosts = @client.__extract_hosts [{:host => 'myhost', :port => '1000', :foo => 'bar'}]

        assert_equal 'myhost', hosts[0][:host]
        assert_equal 1000,     hosts[0][:port]
        assert_equal 'bar',    hosts[0][:foo]
      end

      should "use URL instance" do
        require 'uri'
        hosts = @client.__extract_hosts URI.parse('https://USERNAME:PASSWORD@myhost:4430')

        assert_equal 'https',    hosts[0][:scheme]
        assert_equal 'USERNAME', hosts[0][:user]
        assert_equal 'PASSWORD', hosts[0][:password]
        assert_equal 'myhost',   hosts[0][:host]
        assert_equal 4430,       hosts[0][:port]
      end

      should "split comma-separated URLs" do
        hosts = @client.__extract_hosts 'foo, bar'

        assert_equal 2, hosts.size

        assert_equal 'foo', hosts[0][:host]
        assert_equal 'bar', hosts[1][:host]
      end

      should "remove trailing slash from URL path" do
        hosts = @client.__extract_hosts 'http://myhost/'
        assert_equal '', hosts[0][:path]

        hosts = @client.__extract_hosts 'http://myhost/foo/bar/'
        assert_equal '/foo/bar', hosts[0][:path]
      end

      should "raise error for incompatible argument" do
        assert_raise ArgumentError do
          @client.__extract_hosts 123
        end
      end

      should "randomize hosts" do
        hosts = [ {:host => 'host1'}, {:host => 'host2'}, {:host => 'host3'}, {:host => 'host4'}, {:host => 'host5'}]

        Array.any_instance.expects(:shuffle!).twice

        @client.__extract_hosts(hosts, :randomize_hosts => true)
        assert_same_elements hosts, @client.__extract_hosts(hosts, :randomize_hosts => true)
      end
    end

    context "detecting adapter for Faraday" do
      setup do
        Elasticsearch::Transport::Client::DEFAULT_TRANSPORT_CLASS.any_instance.unstub(:__build_connections)
        begin; Object.send(:remove_const, :Typhoeus); rescue NameError; end
        begin; Object.send(:remove_const, :Patron);   rescue NameError; end
      end

      should "use the default adapter" do
        c = Elasticsearch::Transport::Client.new
        handlers = c.transport.connections.all.first.connection.builder.handlers

        assert_includes handlers, Faraday::Adapter::NetHttp
      end

      should "use the adapter from arguments" do
        c = Elasticsearch::Transport::Client.new :adapter => :typhoeus
        handlers = c.transport.connections.all.first.connection.builder.handlers

        assert_includes handlers, Faraday::Adapter::Typhoeus
      end

      should "detect the adapter" do
        require 'patron'; load 'patron.rb'

        c = Elasticsearch::Transport::Client.new
        handlers = c.transport.connections.all.first.connection.builder.handlers

        assert_includes handlers, Faraday::Adapter::Patron
      end unless JRUBY
    end

    context "configuring Faraday" do
      setup do
        Elasticsearch::Transport::Client::DEFAULT_TRANSPORT_CLASS.any_instance.unstub(:__build_connections)
        begin; Object.send(:remove_const, :Typhoeus); rescue NameError; end
      end

      should "apply faraday adapter" do
        c = Elasticsearch::Transport::Client.new do |faraday|
          faraday.adapter :typhoeus
        end
        handlers = c.transport.connections.all.first.connection.builder.handlers

        assert_includes handlers, Faraday::Adapter::Typhoeus
      end

      should "apply faraday response logger" do
        c = Elasticsearch::Transport::Client.new do |faraday|
          faraday.response :logger
        end
        handlers = c.transport.connections.all.first.connection.builder.handlers

        assert_includes handlers, Faraday::Response::Logger
      end
    end

    context "when passed options" do
      setup do
        Elasticsearch::Transport::Client::DEFAULT_TRANSPORT_CLASS.any_instance.unstub(:__build_connections)
      end

      should "configure the HTTP scheme" do
        c = Elasticsearch::Transport::Client.new \
          :hosts => ['node1', 'node2'],
          :port => 1234, :scheme => 'https', :user => 'USERNAME', :password => 'PASSWORD'

        assert_equal 'https://USERNAME:PASSWORD@node1:1234/', c.transport.connections[0].full_url('')
        assert_equal 'https://USERNAME:PASSWORD@node2:1234/', c.transport.connections[1].full_url('')
      end

      should "keep the credentials after reloading" do
        Elasticsearch::Transport::Client::DEFAULT_TRANSPORT_CLASS.any_instance.
          stubs(:sniffer).
          returns( mock(:hosts => [ {:host => 'foobar', :port => 4567, :id => 'foobar4567'} ]) )

        c = Elasticsearch::Transport::Client.new \
          :url => 'http://foo:1234',
          :user => 'USERNAME', :password => 'PASSWORD'

        assert_equal 'http://USERNAME:PASSWORD@foo:1234/', c.transport.connections.first.full_url('')

        c.transport.reload_connections!

        assert_equal 'http://USERNAME:PASSWORD@foobar:4567/', c.transport.connections.first.full_url('')
      end

      should "transfer selected host parts into the 'http' options" do
        c = Elasticsearch::Transport::Client.new \
          :host => { :scheme => 'https', :port => '8080', :host => 'node1', :user => 'U', :password => 'P' }

        assert_equal 'https://U:P@node1:8080/', c.transport.connections.first.full_url('')

        assert_equal 'https', c.transport.options[:http][:scheme]
        assert_equal 8080,    c.transport.options[:http][:port]
        assert_equal 'U',     c.transport.options[:http][:user]
        assert_equal 'P',     c.transport.options[:http][:password]
      end

      should "transfer selected host parts from URL into the 'http' options" do
        c = Elasticsearch::Transport::Client.new :url => 'https://U:P@node1:8080'

        assert_equal 'https://U:P@node1:8080/', c.transport.connections.first.full_url('')

        assert_equal 'https', c.transport.options[:http][:scheme]
        assert_equal 8080,    c.transport.options[:http][:port]
        assert_equal 'U',     c.transport.options[:http][:user]
        assert_equal 'P',     c.transport.options[:http][:password]
      end
    end

  end
end
