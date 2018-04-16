module OmniAuth
  # Support for testing OmniAuth strategies.
  module Test
    autoload :PhonySession,     'omniauth/test/phony_session'
    autoload :StrategyMacros,   'omniauth/test/strategy_macros'
    autoload :StrategyTestCase, 'omniauth/test/strategy_test_case'
  end
end
