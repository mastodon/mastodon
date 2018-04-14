module Rack
  class Attack
    class Allow2Ban < Fail2Ban
      class << self
        protected
        def key_prefix
          'allow2ban'
        end

        # everything is the same here except we only return true
        # (blocking the request) if they have tripped the limit.
        def fail!(discriminator, bantime, findtime, maxretry)
          count = cache.count("#{key_prefix}:count:#{discriminator}", findtime)
          if count >= maxretry
            ban!(discriminator, bantime)
          end
          # we may not block them this time, but they're banned for next time
          false
        end
      end
    end
  end
end
