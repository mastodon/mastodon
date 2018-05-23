# encoding: utf-8
# frozen_string_literal: true

require 'tempfile'
require 'securerandom'
require 'io/console'

module TTY
  class Command
    module ChildProcess
      # Execute command in a child process with all IO streams piped
      # in and out. The interface is similar to Process.spawn
      #
      # The caller should ensure that all IO objects are closed
      # when the child process is finished. However, when block
      # is provided this will be taken care of automatically.
      #
      # @param [Cmd] cmd
      #   the command to spawn
      #
      # @return [pid, stdin, stdout, stderr]
      #
      # @api public
      def spawn(cmd)
        process_opts = normalize_redirect_options(cmd.options)
        binmode = cmd.options[:binmode] || false
        pty     = cmd.options[:pty] || false

        pty = try_loading_pty if pty
        require('pty') if pty # load within this scope

        # Create pipes
        in_rd,  in_wr  = pty ? PTY.open : IO.pipe('utf-8') # reading
        out_rd, out_wr = pty ? PTY.open : IO.pipe('utf-8') # writing
        err_rd, err_wr = pty ? PTY.open : IO.pipe('utf-8') # error
        in_wr.sync = true

        if binmode
          in_wr.binmode
          out_rd.binmode
          err_rd.binmode
        end

        if pty
          in_wr.raw!
          out_wr.raw!
          err_wr.raw!
        end

        # redirect fds
        opts = {
          in: in_rd,
          out: out_wr,
          err: err_wr
        }
        unless TTY::Command.windows?
          close_child_fds = {
            in_wr  => :close,
            out_rd => :close,
            err_rd => :close
          }
          opts.merge!(close_child_fds)
        end
        opts.merge!(process_opts)

        pid = Process.spawn(cmd.to_command, opts)

        # close in parent process
        [in_rd, out_wr, err_wr].each { |fd| fd.close if fd }

        tuple = [pid, in_wr, out_rd, err_rd]

        if block_given?
          begin
            return yield(*tuple)
          ensure
            # ensure parent pipes are closed
            [in_wr, out_rd, err_rd].each { |fd| fd.close if fd && !fd.closed? }
          end
        else
          tuple
        end
      end
      module_function :spawn

      # Try loading pty module
      #
      # @return [Boolean]
      #
      # @api private
      def try_loading_pty
        require 'pty'
        true
      rescue LoadError
        warn("Requested PTY device but the system doesn't support it.")
        false
      end
      module_function :try_loading_pty

      # Normalize spawn fd into :in, :out, :err keys.
      #
      # @return [Hash]
      #
      # @api private
      def normalize_redirect_options(options)
        options.reduce({}) do |opts, (key, value)|
          if fd?(key)
            spawn_key, spawn_value = convert(key, value)
            opts[spawn_key] = spawn_value
          elsif key.is_a?(Array) && key.all?(&method(:fd?))
            key.each do |k|
              spawn_key, spawn_value = convert(k, value)
              opts[spawn_key] = spawn_value
            end
          end
          opts
        end
      end
      module_function :normalize_redirect_options

      # Convert option pari to recognized spawn option pair
      #
      # @api private
      def convert(spawn_key, spawn_value)
        key   = fd_to_process_key(spawn_key)
        value = spawn_value

        if key.to_s == 'in'
          value = convert_to_fd(spawn_value)
        end

        if fd?(spawn_value)
          value = fd_to_process_key(spawn_value)
          value = [:child, value] # redirect in child process
        end
        [key, value]
      end
      module_function :convert

      # Determine if object is a fd
      #
      # @return [Boolean]
      #
      # @api private
      def fd?(object)
        case object
        when :stdin, :stdout, :stderr, :in, :out, :err,
             STDIN, STDOUT, STDERR, $stdin, $stdout, $stderr, ::IO
          true
        when ::Integer
          object >= 0
        else
          respond_to?(:to_i) && !object.to_io.nil?
        end
      end
      module_function :fd?

      # Convert fd to name :in, :out, :err
      #
      # @api private
      def fd_to_process_key(object)
        case object
        when STDIN, $stdin, :in, :stdin, 0
          :in
        when STDOUT, $stdout, :out, :stdout, 1
          :out
        when STDERR, $stderr, :err, :stderr, 2
          :err
        when Integer
          object >= 0 ? IO.for_fd(object) : nil
        when IO
          object
        when respond_to?(:to_io)
          object.to_io
        else
          raise ExecuteError, "Wrong execute redirect: #{object.inspect}"
        end
      end
      module_function :fd_to_process_key

      # Convert file name to file handle
      #
      # @api private
      def convert_to_fd(object)
        return object if fd?(object)

        if object.is_a?(::String) && ::File.exist?(object)
          return object
        end

        tmp = ::Tempfile.new(::SecureRandom.uuid.split('-')[0])
        content = try_reading(object)
        tmp.write(content)
        tmp.rewind
        tmp
      end
      module_function :convert_to_fd

      # Attempts to read object content
      #
      # @api private
      def try_reading(object)
        if object.respond_to?(:read)
          object.read
        elsif object.respond_to?(:to_s)
          object.to_s
        else
          object
        end
      end
      module_function :try_reading
    end # ChildProcess
  end # Command
end # TTY
