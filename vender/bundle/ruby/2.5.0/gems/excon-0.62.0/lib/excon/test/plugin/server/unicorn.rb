module Excon
  module Test
    module Plugin
      module Server
        module Unicorn
          def start(app_str = app, bind_uri = bind)
            bind_uri = URI.parse(bind_uri) unless bind_uri.is_a? URI::Generic
            is_unix_socket = (bind_uri.scheme == "unix")
            if is_unix_socket
              bind_str = bind_uri.to_s
            else
              host = bind_uri.host.gsub(/[\[\]]/, '')
              bind_str = "#{host}:#{bind_uri.port}"
            end
            args = [ 
              'unicorn', 
              '--no-default-middleware', 
              '-l',
              bind_str,  
              app_str
            ]
            open_process(*args)
            line = ''
            until line =~ /worker\=0 ready/
              line = error.gets
              fatal_time = elapsed_time > timeout
              raise 'unicorn server has taken too long to start' if fatal_time
            end
            true
          end
        end
      end
    end
  end
end
