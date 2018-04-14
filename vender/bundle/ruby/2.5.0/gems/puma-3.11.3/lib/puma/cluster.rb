require 'puma/runner'
require 'puma/util'
require 'puma/plugin'

require 'time'

module Puma
  class Cluster < Runner
    WORKER_CHECK_INTERVAL = 5

    def initialize(cli, events)
      super cli, events

      @phase = 0
      @workers = []
      @next_check = nil

      @phased_state = :idle
      @phased_restart = false
    end

    def stop_workers
      log "- Gracefully shutting down workers..."
      @workers.each { |x| x.term }

      begin
        @workers.each { |w| Process.waitpid(w.pid) }
      rescue Interrupt
        log "! Cancelled waiting for workers"
      end
    end

    def start_phased_restart
      @phase += 1
      log "- Starting phased worker restart, phase: #{@phase}"

      # Be sure to change the directory again before loading
      # the app. This way we can pick up new code.
      dir = @launcher.restart_dir
      log "+ Changing to #{dir}"
      Dir.chdir dir
    end

    def redirect_io
      super

      @workers.each { |x| x.hup }
    end

    class Worker
      def initialize(idx, pid, phase, options)
        @index = idx
        @pid = pid
        @phase = phase
        @stage = :started
        @signal = "TERM"
        @options = options
        @first_term_sent = nil
        @last_checkin = Time.now
        @last_status = '{}'
        @dead = false
      end

      attr_reader :index, :pid, :phase, :signal, :last_checkin, :last_status

      def booted?
        @stage == :booted
      end

      def boot!
        @last_checkin = Time.now
        @stage = :booted
      end

      def dead?
        @dead
      end

      def dead!
        @dead = true
      end

      def ping!(status)
        @last_checkin = Time.now
        @last_status = status
      end

      def ping_timeout?(which)
        Time.now - @last_checkin > which
      end

      def term
        begin
          if @first_term_sent && (Time.now - @first_term_sent) > @options[:worker_shutdown_timeout]
            @signal = "KILL"
          else
            @first_term_sent ||= Time.now
          end

          Process.kill @signal, @pid
        rescue Errno::ESRCH
        end
      end

      def kill
        Process.kill "KILL", @pid
      rescue Errno::ESRCH
      end

      def hup
        Process.kill "HUP", @pid
      rescue Errno::ESRCH
      end
    end

    def spawn_workers
      diff = @options[:workers] - @workers.size
      return if diff < 1

      master = Process.pid

      diff.times do
        idx = next_worker_index
        @launcher.config.run_hooks :before_worker_fork, idx

        pid = fork { worker(idx, master) }
        if !pid
          log "! Complete inability to spawn new workers detected"
          log "! Seppuku is the only choice."
          exit! 1
        end

        debug "Spawned worker: #{pid}"
        @workers << Worker.new(idx, pid, @phase, @options)

        @launcher.config.run_hooks :after_worker_fork, idx
      end

      if diff > 0
        @phased_state = :idle
      end
    end

    def cull_workers
      diff = @workers.size - @options[:workers]
      return if diff < 1

      debug "Culling #{diff.inspect} workers"

      workers_to_cull = @workers[-diff,diff]
      debug "Workers to cull: #{workers_to_cull.inspect}"

      workers_to_cull.each do |worker|
        log "- Worker #{worker.index} (pid: #{worker.pid}) terminating"
        worker.term
      end
    end

    def next_worker_index
      all_positions =  0...@options[:workers]
      occupied_positions = @workers.map { |w| w.index }
      available_positions = all_positions.to_a - occupied_positions
      available_positions.first
    end

    def all_workers_booted?
      @workers.count { |w| !w.booted? } == 0
    end

    def check_workers(force=false)
      return if !force && @next_check && @next_check >= Time.now

      @next_check = Time.now + WORKER_CHECK_INTERVAL

      any = false

      @workers.each do |w|
        next if !w.booted? && !w.ping_timeout?(@options[:worker_boot_timeout])
        if w.ping_timeout?(@options[:worker_timeout])
          log "! Terminating timed out worker: #{w.pid}"
          w.kill
          any = true
        end
      end

      # If we killed any timed out workers, try to catch them
      # during this loop by giving the kernel time to kill them.
      sleep 1 if any

      while @workers.any?
        pid = Process.waitpid(-1, Process::WNOHANG)
        break unless pid

        @workers.delete_if { |w| w.pid == pid }
      end

      @workers.delete_if(&:dead?)

      cull_workers
      spawn_workers

      if all_workers_booted?
        # If we're running at proper capacity, check to see if
        # we need to phase any workers out (which will restart
        # in the right phase).
        #
        w = @workers.find { |x| x.phase != @phase }

        if w
          if @phased_state == :idle
            @phased_state = :waiting
            log "- Stopping #{w.pid} for phased upgrade..."
          end

          w.term
          log "- #{w.signal} sent to #{w.pid}..."
        end
      end
    end

    def wakeup!
      return unless @wakeup

      begin
        @wakeup.write "!" unless @wakeup.closed?
      rescue SystemCallError, IOError
        Thread.current.purge_interrupt_queue if Thread.current.respond_to? :purge_interrupt_queue
      end
    end

    def worker(index, master)
      title  = "puma: cluster worker #{index}: #{master}"
      title += " [#{@options[:tag]}]" if @options[:tag] && !@options[:tag].empty?
      $0 = title

      Signal.trap "SIGINT", "IGNORE"

      @workers = []
      @master_read.close
      @suicide_pipe.close

      Thread.new do
        IO.select [@check_pipe]
        log "! Detected parent died, dying"
        exit! 1
      end

      # If we're not running under a Bundler context, then
      # report the info about the context we will be using
      if !ENV['BUNDLE_GEMFILE']
        if File.exist?("Gemfile")
          log "+ Gemfile in context: #{File.expand_path("Gemfile")}"
        elsif File.exist?("gems.rb")
          log "+ Gemfile in context: #{File.expand_path("gems.rb")}"
        end
      end

      # Invoke any worker boot hooks so they can get
      # things in shape before booting the app.
      @launcher.config.run_hooks :before_worker_boot, index

      server = start_server

      Signal.trap "SIGTERM" do
        server.stop
      end

      begin
        @worker_write << "b#{Process.pid}\n"
      rescue SystemCallError, IOError
        Thread.current.purge_interrupt_queue if Thread.current.respond_to? :purge_interrupt_queue
        STDERR.puts "Master seems to have exited, exiting."
        return
      end

      Thread.new(@worker_write) do |io|
        base_payload = "p#{Process.pid}"

        while true
          sleep WORKER_CHECK_INTERVAL
          begin
            b = server.backlog || 0
            r = server.running || 0
            payload = %Q!#{base_payload}{ "backlog":#{b}, "running":#{r} }\n!
            io << payload
          rescue IOError
            Thread.current.purge_interrupt_queue if Thread.current.respond_to? :purge_interrupt_queue
            break
          end
        end
      end

      server.run.join

      # Invoke any worker shutdown hooks so they can prevent the worker
      # exiting until any background operations are completed
      @launcher.config.run_hooks :before_worker_shutdown, index
    ensure
      @worker_write << "t#{Process.pid}\n" rescue nil
      @worker_write.close
    end

    def restart
      @restart = true
      stop
    end

    def phased_restart
      return false if @options[:preload_app]

      @phased_restart = true
      wakeup!

      true
    end

    def stop
      @status = :stop
      wakeup!
    end

    def stop_blocked
      @status = :stop if @status == :run
      wakeup!
      @control.stop(true) if @control
      Process.waitall
    end

    def halt
      @status = :halt
      wakeup!
    end

    def reload_worker_directory
      dir = @launcher.restart_dir
      log "+ Changing to #{dir}"
      Dir.chdir dir
    end

    def stats
      old_worker_count = @workers.count { |w| w.phase != @phase }
      booted_worker_count = @workers.count { |w| w.booted? }
      worker_status = '[' + @workers.map { |w| %Q!{ "pid": #{w.pid}, "index": #{w.index}, "phase": #{w.phase}, "booted": #{w.booted?}, "last_checkin": "#{w.last_checkin.utc.iso8601}", "last_status": #{w.last_status} }!}.join(",") + ']'
      %Q!{ "workers": #{@workers.size}, "phase": #{@phase}, "booted_workers": #{booted_worker_count}, "old_workers": #{old_worker_count}, "worker_status": #{worker_status} }!
    end

    def preload?
      @options[:preload_app]
    end

    # We do this in a separate method to keep the lambda scope
    # of the signals handlers as small as possible.
    def setup_signals
      Signal.trap "SIGCHLD" do
        wakeup!
      end

      Signal.trap "TTIN" do
        @options[:workers] += 1
        wakeup!
      end

      Signal.trap "TTOU" do
        @options[:workers] -= 1 if @options[:workers] >= 2
        wakeup!
      end

      master_pid = Process.pid

      Signal.trap "SIGTERM" do
        # The worker installs their own SIGTERM when booted.
        # Until then, this is run by the worker and the worker
        # should just exit if they get it.
        if Process.pid != master_pid
          log "Early termination of worker"
          exit! 0
        else
          stop_workers
          stop

          raise SignalException, "SIGTERM"
        end
      end
    end

    def run
      @status = :run

      output_header "cluster"

      log "* Process workers: #{@options[:workers]}"

      before = Thread.list

      if preload?
        log "* Preloading application"
        load_and_bind

        after = Thread.list

        if after.size > before.size
          threads = (after - before)
          if threads.first.respond_to? :backtrace
            log "! WARNING: Detected #{after.size-before.size} Thread(s) started in app boot:"
            threads.each do |t|
              log "! #{t.inspect} - #{t.backtrace ? t.backtrace.first : ''}"
            end
          else
            log "! WARNING: Detected #{after.size-before.size} Thread(s) started in app boot"
          end
        end
      else
        log "* Phased restart available"

        unless @launcher.config.app_configured?
          error "No application configured, nothing to run"
          exit 1
        end

        @launcher.binder.parse @options[:binds], self
      end

      read, @wakeup = Puma::Util.pipe

      setup_signals

      # Used by the workers to detect if the master process dies.
      # If select says that @check_pipe is ready, it's because the
      # master has exited and @suicide_pipe has been automatically
      # closed.
      #
      @check_pipe, @suicide_pipe = Puma::Util.pipe

      if daemon?
        log "* Daemonizing..."
        Process.daemon(true)
      else
        log "Use Ctrl-C to stop"
      end

      redirect_io

      Plugins.fire_background

      @launcher.write_state

      start_control

      @master_read, @worker_write = read, @wakeup

      @launcher.config.run_hooks :before_fork, nil

      spawn_workers

      Signal.trap "SIGINT" do
        stop
      end

      @launcher.events.fire_on_booted!

      begin
        force_check = false

        while @status == :run
          begin
            if @phased_restart
              start_phased_restart
              @phased_restart = false
            end

            check_workers force_check

            force_check = false

            res = IO.select([read], nil, nil, WORKER_CHECK_INTERVAL)

            if res
              req = read.read_nonblock(1)

              next if !req || req == "!"

              result = read.gets
              pid = result.to_i

              if w = @workers.find { |x| x.pid == pid }
                case req
                when "b"
                  w.boot!
                  log "- Worker #{w.index} (pid: #{pid}) booted, phase: #{w.phase}"
                  force_check = true
                when "t"
                  w.dead!
                  force_check = true
                when "p"
                  w.ping!(result.sub(/^\d+/,'').chomp)
                end
              else
                log "! Out-of-sync worker list, no #{pid} worker"
              end
            end

          rescue Interrupt
            @status = :stop
          end
        end

        stop_workers unless @status == :halt
      ensure
        @check_pipe.close
        @suicide_pipe.close
        read.close
        @wakeup.close
      end
    end
  end
end
