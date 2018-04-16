require "shellwords"
require "yaml"
require "socket"
require "webpacker/runner"

module Webpacker
  class DevServerRunner < Webpacker::Runner
    def run
      load_config
      detect_port!
      execute_cmd
    end

    private
      def load_config
        @config_file = File.join(@app_path, "config/webpacker.yml")
        dev_server = YAML.load_file(@config_file)[ENV["RAILS_ENV"]]["dev_server"]

        @hostname          = dev_server["host"]
        @port              = dev_server["port"]
        @pretty            = dev_server.fetch("pretty", true)

      rescue Errno::ENOENT, NoMethodError
        $stdout.puts "webpack dev_server configuration not found in #{@config_file}[#{ENV["RAILS_ENV"]}]."
        $stdout.puts "Please run bundle exec rails webpacker:install to install Webpacker"
        exit!
      end

      def detect_port!
        server = TCPServer.new(@hostname, @port)
        server.close

      rescue Errno::EADDRINUSE
        $stdout.puts "Another program is running on port #{@port}. Set a new port in #{@config_file} for dev_server"
        exit!
      end

      def execute_cmd
        env = { "NODE_PATH" => @node_modules_path.shellescape }
        cmd = [
          "#{@node_modules_path}/.bin/webpack-dev-server",
          "--config", @webpack_config
        ]
        cmd += ["--progress", "--color"] if @pretty

        Dir.chdir(@app_path) do
          exec env, *cmd
        end
      end
  end
end
