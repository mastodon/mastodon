# Rely on autoloading instead of explicit require; helps avoid the "already
# initialized constant" warning on Ruby 1.8.7 when NetHttp is refereced below.
# require 'faraday/adapter/net_http'

module Faraday
  class Adapter
    class NetHttpPersistent < NetHttp
      dependency 'net/http/persistent'

      def net_http_connection(env)
        proxy_uri = nil
        if (proxy = env[:request][:proxy])
          proxy_uri = ::URI::HTTP === proxy[:uri] ? proxy[:uri].dup : ::URI.parse(proxy[:uri].to_s)
          proxy_uri.user = proxy_uri.password = nil
          # awful patch for net-http-persistent 2.8 not unescaping user/password
          (class << proxy_uri; self; end).class_eval do
            define_method(:user) { proxy[:user] }
            define_method(:password) { proxy[:password] }
          end if proxy[:user]
        end

        if Net::HTTP::Persistent.instance_method(:initialize).parameters.first == [:key, :name]
          Net::HTTP::Persistent.new(name: 'Faraday', proxy: proxy_uri)
        else
          Net::HTTP::Persistent.new('Faraday', proxy_uri)
        end
      end

      def perform_request(http, env)
        http.request env[:url], create_request(env)
      rescue Errno::ETIMEDOUT => error
        raise Faraday::Error::TimeoutError, error
      rescue Net::HTTP::Persistent::Error => error
        if error.message.include? 'Timeout'
          raise Faraday::Error::TimeoutError, error
        elsif error.message.include? 'connection refused'
          raise Faraday::Error::ConnectionFailed, error
        else
          raise
        end
      end

      def configure_ssl(http, ssl)
        http.verify_mode  = ssl_verify_mode(ssl)
        http.cert_store   = ssl_cert_store(ssl)

        http.certificate  = ssl[:client_cert]  if ssl[:client_cert]
        http.private_key  = ssl[:client_key]   if ssl[:client_key]
        http.ca_file      = ssl[:ca_file]      if ssl[:ca_file]
        http.ssl_version  = ssl[:version]      if ssl[:version]
      end
    end
  end
end
