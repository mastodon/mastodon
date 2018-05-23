module Excon
  module Test
    module Plugin
      module Server
        module Webrick
          def start(app_str = app, bind_uri = bind)
            bind_uri = URI.parse(bind_uri) unless bind_uri.is_a? URI::Generic
            host = bind_uri.host.gsub(/[\[\]]/, '')
            port = bind_uri.port.to_s
            open_process('rackup', '-s', 'webrick', '--host', host, '--port', port, app_str)
            line = ''
            until line =~ /HTTPServer#start/
              line = error.gets
              fatal_time = elapsed_time > timeout
              raise 'webrick server has taken too long to start' if fatal_time
            end
            true
          end
        end
      end
    end
  end
end
