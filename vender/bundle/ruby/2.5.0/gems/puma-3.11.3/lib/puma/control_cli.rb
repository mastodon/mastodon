require 'optparse'
require 'puma/state_file'
require 'puma/const'
require 'puma/detect'
require 'puma/configuration'
require 'uri'
require 'socket'

module Puma
  class ControlCLI

    COMMANDS = %w{halt restart phased-restart start stats status stop reload-worker-directory gc gc-stats}

    def initialize(argv, stdout=STDOUT, stderr=STDERR)
      @state = nil
      @quiet = false
      @pidfile = nil
      @pid = nil
      @control_url = nil
      @control_auth_token = nil
      @config_file = nil
      @command = nil

      @argv = argv.dup
      @stdout = stdout
      @stderr = stderr
      @cli_options = {}

      opts = OptionParser.new do |o|
        o.banner = "Usage: pumactl (-p PID | -P pidfile | -S status_file | -C url -T token | -F config.rb) (#{COMMANDS.join("|")})"

        o.on "-S", "--state PATH", "Where the state file to use is" do |arg|
          @state = arg
        end

        o.on "-Q", "--quiet", "Not display messages" do |arg|
          @quiet = true
        end

        o.on "-P", "--pidfile PATH", "Pid file" do |arg|
          @pidfile = arg
        end

        o.on "-p", "--pid PID", "Pid" do |arg|
          @pid = arg.to_i
        end

        o.on "-C", "--control-url URL", "The bind url to use for the control server" do |arg|
          @control_url = arg
        end

        o.on "-T", "--control-token TOKEN", "The token to use as authentication for the control server" do |arg|
          @control_auth_token = arg
        end

        o.on "-F", "--config-file PATH", "Puma config script" do |arg|
          @config_file = arg
        end

        o.on_tail("-H", "--help", "Show this message") do
          @stdout.puts o
          exit
        end

        o.on_tail("-V", "--version", "Show version") do
          puts Const::PUMA_VERSION
          exit
        end
      end

      opts.order!(argv) { |a| opts.terminate a }

      @command = argv.shift

      unless @config_file == '-'
        if @config_file.nil? and File.exist?('config/puma.rb')
          @config_file = 'config/puma.rb'
        end

        if @config_file
          config = Puma::Configuration.new({ config_files: [@config_file] }, {})
          config.load
          @state              ||= config.options[:state]
          @control_url        ||= config.options[:control_url]
          @control_auth_token ||= config.options[:control_auth_token]
          @pidfile            ||= config.options[:pidfile]
        end
      end

      # check present of command
      unless @command
        raise "Available commands: #{COMMANDS.join(", ")}"
      end

      unless COMMANDS.include? @command
        raise "Invalid command: #{@command}"
      end

    rescue => e
      @stdout.puts e.message
      @stdout.puts e.backtrace
      exit 1
    end

    def message(msg)
      @stdout.puts msg unless @quiet
    end

    def prepare_configuration
      if @state
        unless File.exist? @state
          raise "State file not found: #{@state}"
        end

        sf = Puma::StateFile.new
        sf.load @state

        @control_url = sf.control_url
        @control_auth_token = sf.control_auth_token
        @pid = sf.pid
      elsif @pidfile
        # get pid from pid_file
        @pid = File.open(@pidfile).gets.to_i
      end
    end

    def send_request
      uri = URI.parse @control_url

      # create server object by scheme
      @server = case uri.scheme
                when "tcp"
                  TCPSocket.new uri.host, uri.port
                when "unix"
                  UNIXSocket.new "#{uri.host}#{uri.path}"
                else
                  raise "Invalid scheme: #{uri.scheme}"
                end

      if @command == "status"
        message "Puma is started"
      else
        url = "/#{@command}"

        if @control_auth_token
          url = url + "?token=#{@control_auth_token}"
        end

        @server << "GET #{url} HTTP/1.0\r\n\r\n"

        unless data = @server.read
          raise "Server closed connection before responding"
        end

        response = data.split("\r\n")

        if response.empty?
          raise "Server sent empty response"
        end

        (@http,@code,@message) = response.first.split(" ",3)

        if @code == "403"
          raise "Unauthorized access to server (wrong auth token)"
        elsif @code == "404"
          raise "Command error: #{response.last}"
        elsif @code != "200"
          raise "Bad response from server: #{@code}"
        end

        message "Command #{@command} sent success"
        message response.last if @command == "stats" || @command == "gc-stats"
      end

      @server.close
    end

    def send_signal
      unless @pid
        raise "Neither pid nor control url available"
      end

      begin

        case @command
        when "restart"
          Process.kill "SIGUSR2", @pid

        when "halt"
          Process.kill "QUIT", @pid

        when "stop"
          Process.kill "SIGTERM", @pid

        when "stats"
          puts "Stats not available via pid only"
          return

        when "reload-worker-directory"
          puts "reload-worker-directory not available via pid only"
          return

        when "phased-restart"
          Process.kill "SIGUSR1", @pid

        else
          message "Puma is started"
          return
        end

      rescue SystemCallError
        if @command == "restart"
          start
        else
          raise "No pid '#{@pid}' found"
        end
      end

      message "Command #{@command} sent success"
    end

    def run
      start if @command == "start"

      prepare_configuration

      if Puma.windows?
        send_request
      else
        @control_url ? send_request : send_signal
      end

    rescue => e
      message e.message
      message e.backtrace
      exit 1
    end

  private
    def start
      require 'puma/cli'

      run_args = []

      run_args += ["-S", @state]  if @state
      run_args += ["-q"] if @quiet
      run_args += ["--pidfile", @pidfile] if @pidfile
      run_args += ["--control-url", @control_url] if @control_url
      run_args += ["--control-token", @control_auth_token] if @control_auth_token
      run_args += ["-C", @config_file] if @config_file

      events = Puma::Events.new @stdout, @stderr

      # replace $0 because puma use it to generate restart command
      puma_cmd = $0.gsub(/pumactl$/, 'puma')
      $0 = puma_cmd if File.exist?(puma_cmd)

      cli = Puma::CLI.new run_args, events
      cli.run
    end
  end
end
