require "#{File.dirname(__FILE__)}/../testrequest"

$stderr = File.open("#{File.dirname(__FILE__)}/log_output", "w")

class EnvMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    # provides a way to test that lint is present
    if env["PATH_INFO"] == "/broken_lint"
      return [200, {}, ["Broken Lint"]]
    # provides a way to kill the process without knowing the pid
    elsif env["PATH_INFO"] == "/die"
      exit!
    end

    env["test.$DEBUG"]      = $DEBUG
    env["test.$EVAL"]       = BUKKIT if defined?(BUKKIT)
    env["test.$VERBOSE"]    = $VERBOSE
    env["test.$LOAD_PATH"]  = $LOAD_PATH
    env["test.stderr"]      = File.expand_path($stderr.path)
    env["test.Ping"]        = defined?(Ping)
    env["test.pid"]         = Process.pid
    @app.call(env)
  end
end

use EnvMiddleware
run TestRequest.new
