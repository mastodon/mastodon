require 'rack'
require 'forwardable'
require 'rack/attack/path_normalizer'
require 'rack/attack/request'
require "ipaddr"

class Rack::Attack
  class MisconfiguredStoreError < StandardError; end
  class MissingStoreError < StandardError; end

  autoload :Cache,           'rack/attack/cache'
  autoload :Check,           'rack/attack/check'
  autoload :Throttle,        'rack/attack/throttle'
  autoload :Safelist,        'rack/attack/safelist'
  autoload :Blocklist,       'rack/attack/blocklist'
  autoload :Track,           'rack/attack/track'
  autoload :StoreProxy,      'rack/attack/store_proxy'
  autoload :DalliProxy,      'rack/attack/store_proxy/dalli_proxy'
  autoload :MemCacheProxy,   'rack/attack/store_proxy/mem_cache_proxy'
  autoload :RedisStoreProxy, 'rack/attack/store_proxy/redis_store_proxy'
  autoload :Fail2Ban,        'rack/attack/fail2ban'
  autoload :Allow2Ban,       'rack/attack/allow2ban'

  class << self

    attr_accessor :notifier, :blocklisted_response, :throttled_response

    def safelist(name, &block)
      self.safelists[name] = Safelist.new(name, block)
    end

    def whitelist(name, &block)
      warn "[DEPRECATION] 'Rack::Attack.whitelist' is deprecated.  Please use 'safelist' instead."
      safelist(name, &block)
    end

    def blocklist(name, &block)
      self.blocklists[name] = Blocklist.new(name, block)
    end

    def blocklist_ip(ip)
      @ip_blocklists ||= []
      ip_blocklist_proc = lambda { |request| IPAddr.new(ip).include?(IPAddr.new(request.ip)) }
      @ip_blocklists << Blocklist.new(nil, ip_blocklist_proc)
    end

    def safelist_ip(ip)
      @ip_safelists ||= []
      ip_safelist_proc = lambda { |request| IPAddr.new(ip).include?(IPAddr.new(request.ip)) }
      @ip_safelists << Safelist.new(nil, ip_safelist_proc)
    end

    def blacklist(name, &block)
      warn "[DEPRECATION] 'Rack::Attack.blacklist' is deprecated.  Please use 'blocklist' instead."
      blocklist(name, &block)
    end

    def throttle(name, options, &block)
      self.throttles[name] = Throttle.new(name, options, block)
    end

    def track(name, options = {}, &block)
      self.tracks[name] = Track.new(name, options, block)
    end

    def safelists;  @safelists  ||= {}; end
    def blocklists; @blocklists ||= {}; end
    def throttles;  @throttles  ||= {}; end
    def tracks;     @tracks     ||= {}; end

    def whitelists
      warn "[DEPRECATION] 'Rack::Attack.whitelists' is deprecated.  Please use 'safelists' instead."
      safelists
    end

    def blacklists
      warn "[DEPRECATION] 'Rack::Attack.blacklists' is deprecated.  Please use 'blocklists' instead."
      blocklists
    end

    def safelisted?(req)
      ip_safelists.any? { |safelist| safelist.match?(req) } ||
        safelists.any? { |_name, safelist| safelist.match?(req) }
    end

    def whitelisted?(req)
      warn "[DEPRECATION] 'Rack::Attack.whitelisted?' is deprecated.  Please use 'safelisted?' instead."
      safelisted?(req)
    end

    def blocklisted?(req)
      ip_blocklists.any? { |blocklist| blocklist.match?(req) } ||
        blocklists.any? { |_name, blocklist| blocklist.match?(req) }
    end

    def blacklisted?(req)
      warn "[DEPRECATION] 'Rack::Attack.blacklisted?' is deprecated.  Please use 'blocklisted?' instead."
      blocklisted?(req)
    end

    def throttled?(req)
      throttles.any? do |name, throttle|
        throttle[req]
      end
    end

    def tracked?(req)
      tracks.each_value do |tracker|
        tracker[req]
      end
    end

    def instrument(req)
      notifier.instrument('rack.attack', req) if notifier
    end

    def cache
      @cache ||= Cache.new
    end

    def clear!
      @safelists, @blocklists, @throttles, @tracks = {}, {}, {}, {}
      @ip_blocklists = []
      @ip_safelists = []
    end

    def blacklisted_response=(res)
      warn "[DEPRECATION] 'Rack::Attack.blacklisted_response=' is deprecated.  Please use 'blocklisted_response=' instead."
      self.blocklisted_response=(res)
    end

    def blacklisted_response
      warn "[DEPRECATION] 'Rack::Attack.blacklisted_response' is deprecated.  Please use 'blocklisted_response' instead."
      blocklisted_response
    end

    private

    def ip_blocklists
      @ip_blocklists ||= []
    end

    def ip_safelists
      @ip_safelists ||= []
    end
  end

  # Set defaults
  @notifier             = ActiveSupport::Notifications if defined?(ActiveSupport::Notifications)
  @blocklisted_response = lambda {|env| [403, {'Content-Type' => 'text/plain'}, ["Forbidden\n"]] }
  @throttled_response   = lambda {|env|
    retry_after = (env['rack.attack.match_data'] || {})[:period]
    [429, {'Content-Type' => 'text/plain', 'Retry-After' => retry_after.to_s}, ["Retry later\n"]]
  }

  def initialize(app)
    @app = app
  end

  def call(env)
    env['PATH_INFO'] = PathNormalizer.normalize_path(env['PATH_INFO'])
    req = Rack::Attack::Request.new(env)

    if safelisted?(req)
      @app.call(env)
    elsif blocklisted?(req)
      self.class.blocklisted_response.call(env)
    elsif throttled?(req)
      self.class.throttled_response.call(env)
    else
      tracked?(req)
      @app.call(env)
    end
  end

  extend Forwardable
  def_delegators self, :safelisted?,
                       :blocklisted?,
                       :throttled?,
                       :tracked?
end
