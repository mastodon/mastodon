require 'test_helper'

class Elasticsearch::Transport::ClientIntegrationTest < Elasticsearch::Test::IntegrationTestCase
  startup do
    Elasticsearch::Extensions::Test::Cluster.start(number_of_nodes: 2) if ENV['SERVER'] and not Elasticsearch::Extensions::Test::Cluster.running?(number_of_nodes: 2)
  end

  shutdown do
    Elasticsearch::Extensions::Test::Cluster.stop(number_of_nodes: 2) if ENV['SERVER'] and Elasticsearch::Extensions::Test::Cluster.running?(number_of_nodes: 2)
  end

  context "Transport" do
    setup do
      @port = (ENV['TEST_CLUSTER_PORT'] || 9250).to_i
      begin; Object.send(:remove_const, :Patron);   rescue NameError; end
    end

    should "allow to customize the Faraday adapter" do
      require 'typhoeus'
      require 'typhoeus/adapters/faraday'

      transport = Elasticsearch::Transport::Transport::HTTP::Faraday.new \
        :hosts => [ { :host => 'localhost', :port => @port } ] do |f|
          f.response :logger
          f.adapter  :typhoeus
        end

      client = Elasticsearch::Transport::Client.new transport: transport
      client.perform_request 'GET', ''
    end

    should "allow to define connection parameters and pass them" do
      transport = Elasticsearch::Transport::Transport::HTTP::Faraday.new \
                    :hosts => [ { :host => 'localhost', :port => @port } ],
                    :options => { :transport_options => {
                                    :params => { :format => 'yaml' }
                                  }
                                }

      client = Elasticsearch::Transport::Client.new transport: transport
      response = client.perform_request 'GET', ''

      assert response.body.start_with?("---\n"), "Response body should be YAML: #{response.body.inspect}"
    end

    should "use the Curb client" do
      require 'curb'
      require 'elasticsearch/transport/transport/http/curb'

      transport = Elasticsearch::Transport::Transport::HTTP::Curb.new \
        :hosts => [ { :host => 'localhost', :port => @port } ] do |curl|
          curl.verbose = true
        end

      client = Elasticsearch::Transport::Client.new transport: transport
      client.perform_request 'GET', ''
    end unless JRUBY

    should "deserialize JSON responses in the Curb client" do
      require 'curb'
      require 'elasticsearch/transport/transport/http/curb'

      transport = Elasticsearch::Transport::Transport::HTTP::Curb.new \
        :hosts => [ { :host => 'localhost', :port => @port } ] do |curl|
          curl.verbose = true
        end

      client = Elasticsearch::Transport::Client.new transport: transport
      response = client.perform_request 'GET', ''

      assert_respond_to(response.body, :to_hash)
      assert_not_nil response.body['name']
      assert_equal 'application/json', response.headers['content-type']
    end unless JRUBY
  end

end
