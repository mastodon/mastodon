require 'test_helper'

class Elasticsearch::Transport::Transport::SnifferTest < Test::Unit::TestCase

  class DummyTransport
    include Elasticsearch::Transport::Transport::Base
    def __build_connections; hosts; end
  end

  def __nodes_info(json)
    Elasticsearch::Transport::Transport::Response.new 200, MultiJson.load(json)
  end

  DEFAULT_NODES_INFO_RESPONSE = <<-JSON
    {
      "cluster_name" : "elasticsearch_test",
      "nodes" : {
        "N1" : {
          "name" : "Node 1",
          "transport_address" : "127.0.0.1:9300",
          "host" : "testhost1",
          "ip"   : "127.0.0.1",
          "version" : "5.0.0",
          "roles": [
            "master",
            "data",
            "ingest"
          ],
          "attributes": {
            "testattr": "test"
          },
          "http": {
            "bound_address": [
              "[fe80::1]:9250",
              "[::1]:9250",
              "127.0.0.1:9250"
            ],
            "publish_address": "127.0.0.1:9250",
            "max_content_length_in_bytes": 104857600
          }
        }
      }
    }
  JSON

  context "Sniffer" do
    setup do
      @transport = DummyTransport.new
      @sniffer   = Elasticsearch::Transport::Transport::Sniffer.new @transport
    end

    should "be initialized with a transport instance" do
      assert_equal @transport, @sniffer.transport
    end

    should "return an array of hosts as hashes" do
      @transport.expects(:perform_request).returns __nodes_info(DEFAULT_NODES_INFO_RESPONSE)

      hosts = @sniffer.hosts

      assert_equal 1, hosts.size
      assert_equal '127.0.0.1', hosts.first[:host]
      assert_equal '9250',      hosts.first[:port]
      assert_equal 'Node 1',    hosts.first[:name]
    end

    should "return an array of hosts as hostnames when a hostname is returned" do
      @transport.expects(:perform_request).returns __nodes_info <<-JSON
        {
          "nodes" : {
            "N1" : {
              "http": {
                "publish_address": "testhost1.com:9250"
              }
            }
          }
        }
      JSON

      hosts = @sniffer.hosts

      assert_equal 1, hosts.size
      assert_equal 'testhost1.com', hosts.first[:host]
      assert_equal '9250',         hosts.first[:port]
    end

    should "return HTTP hosts for the HTTPS protocol in the transport" do
      @transport = DummyTransport.new :options => { :protocol => 'https' }
      @sniffer   = Elasticsearch::Transport::Transport::Sniffer.new @transport

      @transport.expects(:perform_request).returns __nodes_info(DEFAULT_NODES_INFO_RESPONSE)

      assert_equal 1, @sniffer.hosts.size
    end

    should "skip hosts without a matching transport protocol" do
      @transport = DummyTransport.new
      @sniffer   = Elasticsearch::Transport::Transport::Sniffer.new @transport

      @transport.expects(:perform_request).returns __nodes_info <<-JSON
        {
          "nodes" : {
            "N1" : {
              "foobar": {
                "publish_address": "foobar:1234"
              }
            }
          }
        }
      JSON

      assert_empty @sniffer.hosts
    end

    should "have configurable timeout" do
      @transport = DummyTransport.new :options => { :sniffer_timeout => 0.001 }
      @sniffer   = Elasticsearch::Transport::Transport::Sniffer.new @transport
      assert_equal 0.001, @sniffer.timeout
    end

    should "have settable timeout" do
      @transport = DummyTransport.new
      @sniffer   = Elasticsearch::Transport::Transport::Sniffer.new @transport
      assert_equal 1, @sniffer.timeout

      @sniffer.timeout = 2
      assert_equal 2, @sniffer.timeout
    end

    should "raise error on timeout" do
      @transport.expects(:perform_request).raises(Elasticsearch::Transport::Transport::SnifferTimeoutError)

      # TODO: Try to inject sleep into `perform_request` or make this test less ridiculous anyhow...
      assert_raise Elasticsearch::Transport::Transport::SnifferTimeoutError do
        @sniffer.hosts
      end
    end

    should "randomize hosts" do
      @transport = DummyTransport.new :options => { :randomize_hosts => true }
      @sniffer   = Elasticsearch::Transport::Transport::Sniffer.new @transport

      @transport.expects(:perform_request).returns __nodes_info <<-JSON
        {
          "ok" : true,
          "cluster_name" : "elasticsearch_test",
          "nodes" : {
            "N1" : {
              "name" : "Node 1",
              "http_address" : "inet[/192.168.1.23:9200]"
            },
            "N2" : {
              "name" : "Node 2",
              "http_address" : "inet[/192.168.1.23:9201]"
            },
            "N3" : {
              "name" : "Node 3",
              "http_address" : "inet[/192.168.1.23:9202]"
            },
            "N4" : {
              "name" : "Node 4",
              "http_address" : "inet[/192.168.1.23:9203]"
            },
            "N5" : {
              "name" : "Node 5",
              "http_address" : "inet[/192.168.1.23:9204]"
            }
          }
        }
      JSON

      Array.any_instance.expects(:shuffle!)

      hosts = @sniffer.hosts
    end

  end

end
