require 'test_helper'

module ActiveModelSerializers
  class LoggerTest < ActiveSupport::TestCase
    def test_logger_is_set_to_action_controller_logger_when_initializer_runs
      assert_equal $action_controller_logger, ActionController::Base.logger # rubocop:disable Style/GlobalVars
    end

    def test_logger_can_be_set
      original_logger = ActiveModelSerializers.logger
      logger = Logger.new(STDOUT)

      ActiveModelSerializers.logger = logger

      assert_equal ActiveModelSerializers.logger, logger
    ensure
      ActiveModelSerializers.logger = original_logger
    end
  end
end
