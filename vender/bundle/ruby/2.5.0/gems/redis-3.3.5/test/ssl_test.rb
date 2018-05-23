# encoding: UTF-8

if RUBY_VERSION >= "1.9.3"
  require File.expand_path("helper", File.dirname(__FILE__))

  class SslTest < Test::Unit::TestCase

    include Helper::Client

    driver(:ruby) do

      def test_verified_ssl_connection
        RedisMock.start({ :ping => proc { "+PONG" } }, ssl_server_opts("trusted")) do |port|
          redis = Redis.new(:port => port, :ssl => true, :ssl_params => { :ca_file => ssl_ca_file })
          assert_equal redis.ping, "PONG"
        end
      end

      def test_unverified_ssl_connection
        assert_raise(OpenSSL::SSL::SSLError) do
          RedisMock.start({ :ping => proc { "+PONG" } }, ssl_server_opts("untrusted")) do |port|
            redis = Redis.new(:port => port, :ssl => true, :ssl_params => { :ca_file => ssl_ca_file })
            redis.ping
          end
        end
      end

      def test_ssl_blocking
        RedisMock.start({}, ssl_server_opts("trusted")) do |port|
          redis = Redis.new(:port => port, :ssl => true, :ssl_params => { :ca_file => ssl_ca_file })
          assert_equal redis.set("boom", "a" * 10_000_000), "OK"
        end
      end

    end

    driver(:hiredis, :synchrony) do

      def test_ssl_not_implemented_exception
        assert_raise(NotImplementedError) do
          RedisMock.start({ :ping => proc { "+PONG" } }, ssl_server_opts("trusted")) do |port|
            redis = Redis.new(:port => port, :ssl => true, :ssl_params => { :ca_file => ssl_ca_file })
            redis.ping
          end
        end
      end

    end

    private

    def ssl_server_opts(prefix)
      ssl_cert = File.join(cert_path, "#{prefix}-cert.crt")
      ssl_key  = File.join(cert_path, "#{prefix}-cert.key")

      {
        :ssl => true,
        :ssl_params => {
          :cert => OpenSSL::X509::Certificate.new(File.read(ssl_cert)),
          :key  => OpenSSL::PKey::RSA.new(File.read(ssl_key))
        }
      }
    end

    def ssl_ca_file
      File.join(cert_path, "trusted-ca.crt")
    end

    def cert_path
      File.expand_path("../support/ssl/", __FILE__)
    end
  end
end
