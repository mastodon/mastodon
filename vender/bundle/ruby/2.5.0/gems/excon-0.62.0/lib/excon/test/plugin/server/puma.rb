module Excon
  module Test
    module Plugin
      module Server
        module Puma
          def start(app_str = app, bind_uri = bind)
            open_process('puma', '-b', bind_uri.to_s, app_str)
            line = ''
            until line =~ /Use Ctrl-C to stop/
              line = read.gets
              fatal_time = elapsed_time > timeout
              raise 'puma server has taken too long to start' if fatal_time
            end
            true
          end
        end
      end
    end
  end
end
