module Excon
  module Test
    module Plugin
      module Server
        module Exec
          def start(app_str = app)
            line = ''
            open_process(app)
            until line =~ /\Aready\Z/
              line = error.gets
              fatal_time = elapsed_time > timeout
              if fatal_time
                msg = "executable #{app} has taken too long to start"
                raise msg
              end
            end
            true
          end
        end
      end
    end
  end
end
