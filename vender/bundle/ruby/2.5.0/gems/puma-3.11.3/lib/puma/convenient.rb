require 'puma/launcher'
require 'puma/configuration'

module Puma
  def self.run(opts={})
    cfg = Puma::Configuration.new do |user_config|
      if port = opts[:port]
        user_config.port port
      end

      user_config.quiet

      yield c
    end

    cfg.clamp

    events = Puma::Events.null

    launcher = Puma::Launcher.new cfg, :events => events
    launcher.run
  end
end
