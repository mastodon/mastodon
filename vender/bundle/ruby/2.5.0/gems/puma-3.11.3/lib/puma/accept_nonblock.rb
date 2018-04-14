require 'openssl'

module OpenSSL
  module SSL
    class SSLServer
      unless public_method_defined? :accept_nonblock
        def accept_nonblock
          sock = @svr.accept_nonblock

          begin
            ssl = OpenSSL::SSL::SSLSocket.new(sock, @ctx)
            ssl.sync_close = true
            ssl.accept if @start_immediately
            ssl
          rescue SSLError => ex
            sock.close
            raise ex
          end
        end
      end
    end
  end
end
