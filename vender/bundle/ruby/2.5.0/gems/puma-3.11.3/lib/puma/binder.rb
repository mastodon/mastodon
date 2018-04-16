require 'uri'
require 'socket'

require 'puma/const'
require 'puma/util'

module Puma
  class Binder
    include Puma::Const

    RACK_VERSION = [1,3].freeze

    def initialize(events)
      @events = events
      @listeners = []
      @inherited_fds = {}
      @activated_sockets = {}
      @unix_paths = []

      @proto_env = {
        "rack.version".freeze => RACK_VERSION,
        "rack.errors".freeze => events.stderr,
        "rack.multithread".freeze => true,
        "rack.multiprocess".freeze => false,
        "rack.run_once".freeze => false,
        "SCRIPT_NAME".freeze => ENV['SCRIPT_NAME'] || "",

        # I'd like to set a default CONTENT_TYPE here but some things
        # depend on their not being a default set and inferring
        # it from the content. And so if i set it here, it won't
        # infer properly.

        "QUERY_STRING".freeze => "",
        SERVER_PROTOCOL => HTTP_11,
        SERVER_SOFTWARE => PUMA_SERVER_STRING,
        GATEWAY_INTERFACE => CGI_VER
      }

      @envs = {}
      @ios = []
    end

    attr_reader :listeners, :ios

    def env(sock)
      @envs.fetch(sock, @proto_env)
    end

    def close
      @ios.each { |i| i.close }
      @unix_paths.each { |i| File.unlink i }
    end

    def import_from_env
      remove = []

      ENV.each do |k,v|
        if k =~ /PUMA_INHERIT_\d+/
          fd, url = v.split(":", 2)
          @inherited_fds[url] = fd.to_i
          remove << k
        elsif k == 'LISTEN_FDS' && ENV['LISTEN_PID'].to_i == $$
          v.to_i.times do |num|
            fd = num + 3
            sock = TCPServer.for_fd(fd)
            begin
              key = [ :unix, Socket.unpack_sockaddr_un(sock.getsockname) ]
            rescue ArgumentError
              port, addr = Socket.unpack_sockaddr_in(sock.getsockname)
              if addr =~ /\:/
                addr = "[#{addr}]"
              end
              key = [ :tcp, addr, port ]
            end
            @activated_sockets[key] = sock
            @events.debug "Registered #{key.join ':'} for activation from LISTEN_FDS"
          end
          remove << k << 'LISTEN_PID'
        end
      end

      remove.each do |k|
        ENV.delete k
      end
    end

    def parse(binds, logger)
      binds.each do |str|
        uri = URI.parse str
        case uri.scheme
        when "tcp"
          if fd = @inherited_fds.delete(str)
            logger.log "* Inherited #{str}"
            io = inherit_tcp_listener uri.host, uri.port, fd
          elsif sock = @activated_sockets.delete([ :tcp, uri.host, uri.port ])
            logger.log "* Activated #{str}"
            io = inherit_tcp_listener uri.host, uri.port, sock
          else
            params = Util.parse_query uri.query

            opt = params.key?('low_latency')
            bak = params.fetch('backlog', 1024).to_i

            logger.log "* Listening on #{str}"
            io = add_tcp_listener uri.host, uri.port, opt, bak
          end

          @listeners << [str, io] if io
        when "unix"
          path = "#{uri.host}#{uri.path}".gsub("%20", " ")

          if fd = @inherited_fds.delete(str)
            logger.log "* Inherited #{str}"
            io = inherit_unix_listener path, fd
          elsif sock = @activated_sockets.delete([ :unix, path ])
            logger.log "* Activated #{str}"
            io = inherit_unix_listener path, sock
          else
            logger.log "* Listening on #{str}"

            umask = nil
            mode = nil
            backlog = 1024

            if uri.query
              params = Util.parse_query uri.query
              if u = params['umask']
                # Use Integer() to respect the 0 prefix as octal
                umask = Integer(u)
              end

              if u = params['mode']
                mode = Integer('0'+u)
              end

              if u = params['backlog']
                backlog = Integer(u)
              end
            end

            io = add_unix_listener path, umask, mode, backlog
          end

          @listeners << [str, io]
        when "ssl"
          params = Util.parse_query uri.query
          require 'puma/minissl'

          MiniSSL.check

          ctx = MiniSSL::Context.new

          if defined?(JRUBY_VERSION)
            unless params['keystore']
              @events.error "Please specify the Java keystore via 'keystore='"
            end

            ctx.keystore = params['keystore']

            unless params['keystore-pass']
              @events.error "Please specify the Java keystore password  via 'keystore-pass='"
            end

            ctx.keystore_pass = params['keystore-pass']
          else
            unless params['key']
              @events.error "Please specify the SSL key via 'key='"
            end

            ctx.key = params['key']

            unless params['cert']
              @events.error "Please specify the SSL cert via 'cert='"
            end

            ctx.cert = params['cert']

            if ['peer', 'force_peer'].include?(params['verify_mode'])
              unless params['ca']
                @events.error "Please specify the SSL ca via 'ca='"
              end
            end

            ctx.ca = params['ca'] if params['ca']
          end

          if params['verify_mode']
            ctx.verify_mode = case params['verify_mode']
                              when "peer"
                                MiniSSL::VERIFY_PEER
                              when "force_peer"
                                MiniSSL::VERIFY_PEER | MiniSSL::VERIFY_FAIL_IF_NO_PEER_CERT
                              when "none"
                                MiniSSL::VERIFY_NONE
                              else
                                @events.error "Please specify a valid verify_mode="
                                MiniSSL::VERIFY_NONE
                              end
          end

          if fd = @inherited_fds.delete(str)
            logger.log "* Inherited #{str}"
            io = inherit_ssl_listener fd, ctx
          elsif sock = @activated_sockets.delete([ :tcp, uri.host, uri.port ])
            logger.log "* Activated #{str}"
            io = inherit_ssl_listener sock, ctx
          else
            logger.log "* Listening on #{str}"
            io = add_ssl_listener uri.host, uri.port, ctx
          end

          @listeners << [str, io] if io
        else
          logger.error "Invalid URI: #{str}"
        end
      end

      # If we inherited fds but didn't use them (because of a
      # configuration change), then be sure to close them.
      @inherited_fds.each do |str, fd|
        logger.log "* Closing unused inherited connection: #{str}"

        begin
          IO.for_fd(fd).close
        rescue SystemCallError
        end

        # We have to unlink a unix socket path that's not being used
        uri = URI.parse str
        if uri.scheme == "unix"
          path = "#{uri.host}#{uri.path}"
          File.unlink path
        end
      end

      # Also close any unused activated sockets
      @activated_sockets.each do |key, sock|
        logger.log "* Closing unused activated socket: #{key.join ':'}"
        begin
          sock.close
        rescue SystemCallError
        end
        # We have to unlink a unix socket path that's not being used
        File.unlink key[1] if key[0] == :unix
      end
    end

    def loopback_addresses
      Socket.ip_address_list.select do |addrinfo|
        addrinfo.ipv6_loopback? || addrinfo.ipv4_loopback?
      end.map { |addrinfo| addrinfo.ip_address }.uniq
    end

    # Tell the server to listen on host +host+, port +port+.
    # If +optimize_for_latency+ is true (the default) then clients connecting
    # will be optimized for latency over throughput.
    #
    # +backlog+ indicates how many unaccepted connections the kernel should
    # allow to accumulate before returning connection refused.
    #
    def add_tcp_listener(host, port, optimize_for_latency=true, backlog=1024)
      if host == "localhost"
        loopback_addresses.each do |addr|
          add_tcp_listener addr, port, optimize_for_latency, backlog
        end
        return
      end

      host = host[1..-2] if host and host[0..0] == '['
      s = TCPServer.new(host, port)
      if optimize_for_latency
        s.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      end
      s.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR, true)
      s.listen backlog
      @connected_port = s.addr[1]

      @ios << s
      s
    end

    attr_reader :connected_port

    def inherit_tcp_listener(host, port, fd)
      if fd.kind_of? TCPServer
        s = fd
      else
        s = TCPServer.for_fd(fd)
      end

      @ios << s
      s
    end

    def add_ssl_listener(host, port, ctx,
                         optimize_for_latency=true, backlog=1024)
      require 'puma/minissl'

      MiniSSL.check

      if host == "localhost"
        loopback_addresses.each do |addr|
          add_ssl_listener addr, port, ctx, optimize_for_latency, backlog
        end
        return
      end

      host = host[1..-2] if host[0..0] == '['
      s = TCPServer.new(host, port)
      if optimize_for_latency
        s.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      end
      s.setsockopt(Socket::SOL_SOCKET,Socket::SO_REUSEADDR, true)
      s.listen backlog

      ssl = MiniSSL::Server.new s, ctx
      env = @proto_env.dup
      env[HTTPS_KEY] = HTTPS
      @envs[ssl] = env

      @ios << ssl
      s
    end

    def inherit_ssl_listener(fd, ctx)
      require 'puma/minissl'
      MiniSSL.check

      if fd.kind_of? TCPServer
        s = fd
      else
        s = TCPServer.for_fd(fd)
      end
      ssl = MiniSSL::Server.new(s, ctx)

      env = @proto_env.dup
      env[HTTPS_KEY] = HTTPS
      @envs[ssl] = env

      @ios << ssl

      s
    end

    # Tell the server to listen on +path+ as a UNIX domain socket.
    #
    def add_unix_listener(path, umask=nil, mode=nil, backlog=1024)
      @unix_paths << path

      # Let anyone connect by default
      umask ||= 0

      begin
        old_mask = File.umask(umask)

        if File.exist? path
          begin
            old = UNIXSocket.new path
          rescue SystemCallError, IOError
            File.unlink path
          else
            old.close
            raise "There is already a server bound to: #{path}"
          end
        end

        s = UNIXServer.new(path)
        s.listen backlog
        @ios << s
      ensure
        File.umask old_mask
      end

      if mode
        File.chmod mode, path
      end

      env = @proto_env.dup
      env[REMOTE_ADDR] = "127.0.0.1"
      @envs[s] = env

      s
    end

    def inherit_unix_listener(path, fd)
      @unix_paths << path

      if fd.kind_of? TCPServer
        s = fd
      else
        s = UNIXServer.for_fd fd
      end
      @ios << s

      env = @proto_env.dup
      env[REMOTE_ADDR] = "127.0.0.1"
      @envs[s] = env

      s
    end

  end
end
