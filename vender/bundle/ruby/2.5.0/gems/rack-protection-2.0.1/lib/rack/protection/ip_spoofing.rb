require 'rack/protection'

module Rack
  module Protection
    ##
    # Prevented attack::   IP spoofing
    # Supported browsers:: all
    # More infos::         http://blog.c22.cc/2011/04/22/surveymonkey-ip-spoofing/
    #
    # Detect (some) IP spoofing attacks.
    class IPSpoofing < Base
      default_reaction :deny

      def accepts?(env)
        return true unless env.include? 'HTTP_X_FORWARDED_FOR'
        ips = env['HTTP_X_FORWARDED_FOR'].split(/\s*,\s*/)
        return false if env.include? 'HTTP_CLIENT_IP' and not ips.include? env['HTTP_CLIENT_IP']
        return false if env.include? 'HTTP_X_REAL_IP' and not ips.include? env['HTTP_X_REAL_IP']
        true
      end
    end
  end
end
