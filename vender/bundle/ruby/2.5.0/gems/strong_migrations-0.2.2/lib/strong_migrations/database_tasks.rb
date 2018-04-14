module StrongMigrations
  module DatabaseTasks
    def migrate
      super
    rescue => e
      if e.cause.is_a?(StrongMigrations::UnsafeMigration)
        # strip cause and clean backtrace
        def e.cause
          nil
        end

        def e.message
          super.sub("\n\n\n", "\n\n") + "\n"
        end

        unless Rake.application.options.trace
          def e.backtrace
            bc = ActiveSupport::BacktraceCleaner.new
            bc.add_silencer { |line| line =~ /strong_migrations/ }
            bc.clean(super)
          end
        end
      end

      raise e
    end
  end
end
