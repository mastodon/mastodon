# frozen_string_literal: true

require "coveralls"
Coveralls.wear!

require "bundler/setup"
require "timers"

# Level of accuracy enforced by tests (50ms)
TIMER_QUANTUM = 0.05

RSpec.configure do |config|
  # Setting this config option `false` removes rspec-core's monkey patching of the
  # top level methods like `describe`, `shared_examples_for` and `shared_context`
  # on `main` and `Module`. The methods are always available through the `RSpec`
  # module like `RSpec.describe` regardless of this setting.
  # For backwards compatibility this defaults to `true`.
  #
  # https://relishapp.com/rspec/rspec-core/v/3-0/docs/configuration/global-namespace-dsl
  config.expose_dsl_globally = false
end
