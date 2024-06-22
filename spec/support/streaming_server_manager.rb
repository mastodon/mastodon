# frozen_string_literal: true

class StreamingServerManager
  @running_thread = nil

  def initialize
    at_exit { stop }
  end

  def start(port: 4020)
    return if @running_thread

    queue = Queue.new

    @queue = queue

    @running_thread = Thread.new do
      Open3.popen2e(
        {
          'REDIS_NAMESPACE' => ENV.fetch('REDIS_NAMESPACE'),
          'DB_NAME' => "#{ENV.fetch('DB_NAME', 'mastodon')}_test#{ENV.fetch('TEST_ENV_NUMBER', '')}",
          'RAILS_ENV' => ENV.fetch('RAILS_ENV', 'test'),
          'NODE_ENV' => ENV.fetch('STREAMING_NODE_ENV', 'development'),
          'PORT' => port.to_s,
        },
        'node index.js', # must not call yarn here, otherwise it will fail because yarn does not send signals to its child process
        chdir: Rails.root.join('streaming')
      ) do |_stdin, stdout_err, process_thread|
        status = :starting

        # Spawn a thread to listen on streaming server output
        output_thread = Thread.new do
          stdout_err.each_line do |line|
            Rails.logger.info "Streaming server: #{line}"

            if status == :starting && line.match('Streaming API now listening on')
              status = :started
              @queue.enq 'started'
            end
          end
        end

        # And another thread to listen on commands from the main thread
        loop do
          msg = queue.pop

          case msg
          when 'stop'
            # we need to properly stop the reading thread
            output_thread.kill

            # Then stop the node process
            Process.kill('KILL', process_thread.pid)

            # And we stop ourselves
            @running_thread.kill
          end
        end
      end
    end

    # wait for 10 seconds for the streaming server to start
    Timeout.timeout(10) do
      loop do
        break if @queue.pop == 'started'
      end
    end
  end

  def stop
    return unless @running_thread

    @queue.enq 'stop'

    # Wait for the thread to end
    @running_thread.join
  end
end

RSpec.configure do |config|
  config.before :suite do
    if streaming_examples_present?
      # Start the node streaming server
      streaming_server_manager.start(port: STREAMING_PORT)
    end
  end

  config.after :suite do
    if streaming_examples_present?
      # Stop the node streaming server
      streaming_server_manager.stop
    end
  end

  config.around :each, :streaming, type: :system do |example|
    # Streaming server needs DB access but `use_transactional_tests` rolls back
    # every transaction. Disable this feature for streaming tests, and use
    # DatabaseCleaner to clean the database tables between each test.
    self.use_transactional_tests = false

    DatabaseCleaner.cleaning do
      # NOTE: we switched registrations mode to closed by default, but the specs
      # very heavily rely on having it enabled by default, as it relies on users
      # being approved by default except in select cases where explicitly testing
      # other registration modes
      # Also needs to be set per-example here because of the database cleaner.
      Setting.registrations_mode = 'open'

      # Load seeds so we have the default roles otherwise cleared by `DatabaseCleaner`
      Rails.application.load_seed

      example.run
    end

    self.use_transactional_tests = true
  end

  private

  def streaming_server_manager
    @streaming_server_manager ||= StreamingServerManager.new
  end

  def streaming_examples_present?
    RSpec.world.filtered_examples.values.flatten.any? { |example| example.metadata[:streaming] == true }
  end
end
