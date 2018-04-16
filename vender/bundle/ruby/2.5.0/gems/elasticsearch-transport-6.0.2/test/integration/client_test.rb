require 'test_helper'

class Elasticsearch::Transport::ClientIntegrationTest < Elasticsearch::Test::IntegrationTestCase
  startup do
    Elasticsearch::Extensions::Test::Cluster.start(number_of_nodes: 2) if ENV['SERVER'] and not Elasticsearch::Extensions::Test::Cluster.running?(number_of_nodes: 2)
  end

  shutdown do
    Elasticsearch::Extensions::Test::Cluster.stop(number_of_nodes: 2) if ENV['SERVER'] and Elasticsearch::Extensions::Test::Cluster.running?(number_of_nodes: 2)
  end

  context "Elasticsearch client" do
    teardown do
      begin; Object.send(:remove_const, :Typhoeus);                rescue NameError; end
      begin; Net::HTTP.send(:remove_const, :Persistent); rescue NameError; end
    end

    setup do
      @port = (ENV['TEST_CLUSTER_PORT'] || 9250).to_i
      system "curl -X DELETE http://127.0.0.1:#{@port}/_all > /dev/null 2>&1"

      @logger =  Logger.new(STDERR)
      @logger.formatter = proc do |severity, datetime, progname, msg|
        color = case severity
          when /INFO/ then :green
          when /ERROR|WARN|FATAL/ then :red
          when /DEBUG/ then :cyan
          else :white
        end
        ANSI.ansi(severity[0] + ' ', color, :faint) + ANSI.ansi(msg, :white, :faint) + "\n"
      end

      @client = Elasticsearch::Client.new host: "127.0.0.1:#{@port}"
    end

    should "connect to the cluster" do
      assert_nothing_raised do
        response = @client.perform_request 'GET', '_cluster/health'
        assert_equal 2, response.body['number_of_nodes']
      end
    end

    should "handle paths and URL parameters" do
      @client.perform_request 'PUT', 'myindex/mydoc/1', {routing: 'XYZ'}, {foo: 'bar'}
      @client.perform_request 'GET', '_cluster/health?wait_for_status=green', {}

      response = @client.perform_request 'GET', 'myindex/mydoc/1?routing=XYZ'
      assert_equal 200, response.status
      assert_equal 'bar', response.body['_source']['foo']

      assert_raise Elasticsearch::Transport::Transport::Errors::NotFound do
        @client.perform_request 'GET', 'myindex/mydoc/1?routing=ABC'
      end
    end

    should "ignore specified response codes" do
      response = @client.perform_request 'PUT', '_foobar', ignore: 400
      assert_equal 400, response.status

      assert_instance_of Hash, response.body
      assert_match /invalid_index_name_exception/, response.body.inspect
    end

    should "pass options to the transport" do
      @client = Elasticsearch::Client.new \
        host: "127.0.0.1:#{@port}",
        logger: (ENV['QUIET'] ? nil : @logger),
        transport_options: { headers: { accept: 'application/yaml', content_type: 'application/yaml' } }

      response = @client.perform_request 'GET', '_cluster/health'

      assert response.body.to_s.start_with?("---\n"), "Response body should be YAML: #{response.body.inspect}"
      assert_equal 'application/yaml', response.headers['content-type']
    end

    should "pass request headers to the transport" do
      response = @client.perform_request 'GET', '/', {}, nil, {'Content-Type' => 'application/yaml'}
      assert_match(/---/, response.body)
    end

    should "pass options to the Faraday::Connection with a block" do
      @client = Elasticsearch::Client.new(
        host: "127.0.0.1:#{@port}",
        logger: (ENV['QUIET'] ? nil : @logger)
      ) do |client|
        client.headers['Content-Type'] = 'application/yaml' # For ES 2.x
        client.headers['Accept'] = 'application/yaml'       # For ES 5.x
      end

      response = @client.perform_request 'GET', '_cluster/health'

      assert response.body.to_s.start_with?("---\n"), "Response body should be YAML: #{response.body.inspect}"
      assert_equal 'application/yaml', response.headers['content-type']
    end

    context "with round robin selector" do
      setup do
        @client = Elasticsearch::Client.new \
                    hosts:  ["127.0.0.1:#{@port}", "127.0.0.1:#{@port+1}" ],
                    logger: (ENV['QUIET'] ? nil : @logger)
      end

      should "rotate nodes" do
        # Hit node 1
        response = @client.perform_request 'GET', '_nodes/_local'
        assert_equal 'node-1', response.body['nodes'].to_a[0][1]['name']

        # Hit node 2
        response = @client.perform_request 'GET', '_nodes/_local'
        assert_equal 'node-2', response.body['nodes'].to_a[0][1]['name']

        # Hit node 1
        response = @client.perform_request 'GET', '_nodes/_local'
        assert_equal 'node-1', response.body['nodes'].to_a[0][1]['name']
      end
    end

    context "with a sick node and retry on failure" do
      setup do
        @port = (ENV['TEST_CLUSTER_PORT'] || 9250).to_i
        @client = Elasticsearch::Client.new \
                    hosts: ["127.0.0.1:#{@port}", "foobar1"],
                    logger: (ENV['QUIET'] ? nil : @logger),
                    retry_on_failure: true
      end

      should "retry the request with next server" do
        assert_nothing_raised do
          5.times { @client.perform_request 'GET', '_nodes/_local' }
        end
      end

      should "raise exception when it cannot get any healthy server" do
        @client = Elasticsearch::Client.new \
                  hosts: ["127.0.0.1:#{@port}", "foobar1", "foobar2", "foobar3"],
                  logger: (ENV['QUIET'] ? nil : @logger),
                  retry_on_failure: 1

        assert_nothing_raised do
          # First hit is OK
          @client.perform_request 'GET', '_nodes/_local'
        end

        assert_raise Faraday::Error::ConnectionFailed do
          # Second hit fails
          @client.perform_request 'GET', '_nodes/_local'
        end
      end
    end

    context "with a sick node and reloading on failure" do
      setup do
        @client = Elasticsearch::Client.new \
                  hosts: ["127.0.0.1:#{@port}", "foobar1", "foobar2"],
                  logger: (ENV['QUIET'] ? nil : @logger),
                  reload_on_failure: true
      end

      should "reload the connections" do
        assert_equal 3, @client.transport.connections.size
        assert_nothing_raised do
          5.times { @client.perform_request 'GET', '_nodes/_local' }
        end
        assert_equal 2, @client.transport.connections.size
      end
    end

    context "with retrying on status" do
      should "retry when the status does match" do
        @client = Elasticsearch::Client.new \
                  hosts: ["127.0.0.1:#{@port}"],
                  logger: (ENV['QUIET'] ? nil : @logger),
                  retry_on_status: 400

        # Set the logger when the `QUIET` option is set
        @client.transport.logger ||= Logger.new(STDERR)

        @client.transport.logger.stubs(:fatal)
        @client.transport.logger
          .expects(:warn)
          .with( regexp_matches(/Attempt \d to get response/) )
          .times(4)

        assert_raise Elasticsearch::Transport::Transport::Errors::BadRequest do
          @client.perform_request 'PUT', '_foobar'
        end
      end
    end

    context "when reloading connections" do
      should "keep existing connections" do
        require 'patron' # We need a client with keep-alive
        client = Elasticsearch::Transport::Client.new host: "127.0.0.1:#{@port}",
                                                      adapter: :patron,
                                                      logger: (ENV['QUIET'] ? nil : @logger)

        assert_equal 'Faraday::Adapter::Patron',
                      client.transport.connections.first.connection.builder.handlers.first.name

        response = client.perform_request 'GET', '_nodes/stats/http'

        a = response.body['nodes'].values.select { |n| n['name'] == 'node-1' }.first['http']['total_opened']

        client.transport.reload_connections!

        response = client.perform_request 'GET', '_nodes/stats/http'
        b = response.body['nodes'].values.select { |n| n['name'] == 'node-1' }.first['http']['total_opened']

        assert_equal a, b
      end unless JRUBY
    end

    context "with Faraday adapters" do
      should "set the adapter with a block" do
        require 'net/http/persistent'

        client = Elasticsearch::Transport::Client.new url: "127.0.0.1:#{@port}" do |f|
          f.adapter :net_http_persistent
        end

        assert_equal 'Faraday::Adapter::NetHttpPersistent',
                     client.transport.connections.first.connection.builder.handlers.first.name

        response = @client.perform_request 'GET', '_cluster/health'
        assert_equal 200, response.status
      end

      should "automatically use the Patron client when loaded" do
        teardown { begin; Object.send(:remove_const, :Patron); rescue NameError; end }

        require 'patron'
        client = Elasticsearch::Transport::Client.new host: "127.0.0.1:#{@port}"

        assert_equal 'Faraday::Adapter::Patron',
                      client.transport.connections.first.connection.builder.handlers.first.name

        response = @client.perform_request 'GET', '_cluster/health'
        assert_equal 200, response.status
      end unless JRUBY
    end
  end
end
