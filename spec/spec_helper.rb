# frozen_string_literal: true

if ENV['DISABLE_SIMPLECOV'] != 'true'
  require 'simplecov'
  SimpleCov.start 'rails' do
    add_filter 'lib/linter'
    add_group 'Policies', 'app/policies'
    add_group 'Presenters', 'app/presenters'
    add_group 'Serializers', 'app/serializers'
    add_group 'Services', 'app/services'
    add_group 'Validators', 'app/validators'
  end
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = 'tmp/rspec/examples.txt'
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true

    config.around(:example, :without_verify_partial_doubles) do |example|
      mocks.verify_partial_doubles = false
      example.call
      mocks.verify_partial_doubles = true
    end
  end

  config.before :suite do
    Rails.application.load_seed
    Chewy.strategy(:bypass)
  end

  config.after :suite do
    FileUtils.rm_rf(Dir[Rails.root.join('spec', 'test_files')])
  end
end

def body_as_json
  json_str_to_hash(response.body)
end

def json_str_to_hash(str)
  JSON.parse(str, symbolize_names: true)
end

def expect_push_bulk_to_match(klass, matcher)
  expect(Sidekiq::Client).to receive(:push_bulk).with(hash_including({
    'class' => klass,
    'args' => matcher,
  }))
end

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

class SearchDataManager
  def prepare_test_data
    4.times do |i|
      username = "search_test_account_#{i}"
      account = Fabricate.create(:account, username: username, indexable: i.even?, discoverable: i.even?, note: "Lover of #{i}.")
      2.times do |j|
        Fabricate.create(:status, account: account, text: "#{username}'s #{j} post", visibility: j.even? ? :public : :private)
      end
    end

    3.times do |i|
      Fabricate.create(:tag, name: "search_test_tag_#{i}")
    end
  end

  def indexes
    [
      AccountsIndex,
      PublicStatusesIndex,
      StatusesIndex,
      TagsIndex,
    ]
  end

  def populate_indexes
    indexes.each do |index_class|
      index_class.purge!
      index_class.import!
    end
  end

  def remove_indexes
    indexes.each(&:delete!)
  end

  def cleanup_test_data
    Status.destroy_all
    Account.destroy_all
    Tag.destroy_all
  end
end
