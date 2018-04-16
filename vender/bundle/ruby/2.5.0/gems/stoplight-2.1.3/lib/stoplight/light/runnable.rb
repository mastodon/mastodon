# coding: utf-8

module Stoplight
  class Light
    module Runnable # rubocop:disable Style/Documentation
      # @return [String]
      def color
        failures, state = failures_and_state
        failure = failures.first

        if state == State::LOCKED_GREEN then Color::GREEN
        elsif state == State::LOCKED_RED then Color::RED
        elsif failures.size < threshold then Color::GREEN
        elsif failure && Time.now - failure.time >= cool_off_time
          Color::YELLOW
        else Color::RED
        end
      end

      # @raise [Error::RedLight]
      def run
        case color
        when Color::GREEN then run_green
        when Color::YELLOW then run_yellow
        else run_red
        end
      end

      private

      def run_green
        on_failure = lambda do |size, error|
          notify(Color::GREEN, Color::RED, error) if size == threshold
        end
        run_code(nil, on_failure)
      end

      def run_yellow
        on_success = lambda do |failures|
          notify(Color::RED, Color::GREEN) unless failures.empty?
        end
        run_code(on_success, nil)
      end

      def run_red
        raise Error::RedLight, name unless fallback
        fallback.call(nil)
      end

      def run_code(on_success, on_failure)
        result = code.call
        failures = clear_failures
        on_success.call(failures) if on_success
        result
      rescue Exception => error # rubocop:disable Lint/RescueException
        handle_error(error, on_failure)
      end

      def handle_error(error, on_failure)
        error_handler.call(error, Error::HANDLER)
        size = record_failure(error)
        on_failure.call(size, error) if on_failure
        raise error unless fallback
        fallback.call(error)
      end

      def clear_failures
        safely([]) { data_store.clear_failures(self) }
      end

      def failures_and_state
        safely([[], State::UNLOCKED]) { data_store.get_all(self) }
      end

      def notify(from_color, to_color, error = nil)
        notifiers.each do |notifier|
          safely { notifier.notify(self, from_color, to_color, error) }
        end
      end

      def record_failure(error)
        failure = Failure.from_error(error)
        safely(0) { data_store.record_failure(self, failure) }
      end

      def safely(default = nil, &code)
        return yield if data_store == Default::DATA_STORE

        self
          .class
          .new("#{name}-safely", &code)
          .with_data_store(Default::DATA_STORE)
          .with_fallback do |error|
            error_notifier.call(error) if error
            default
          end
          .run
      end
    end
  end
end
