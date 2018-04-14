# AUTHOR: blink <blinketje@gmail.com>; blink#ruby-lang@irc.freenode.net
# bugrep: Andreas Zehnder

require 'rack'
require 'time'
require 'rack/request'
require 'rack/response'
require 'securerandom'

module Rack

  module Session

    module Abstract
      # SessionHash is responsible to lazily load the session from store.

      class SessionHash
        include Enumerable
        attr_writer :id

        Unspecified = Object.new

        def self.find(req)
          req.get_header RACK_SESSION
        end

        def self.set(req, session)
          req.set_header RACK_SESSION, session
        end

        def self.set_options(req, options)
          req.set_header RACK_SESSION_OPTIONS, options.dup
        end

        def initialize(store, req)
          @store = store
          @req = req
          @loaded = false
        end

        def id
          return @id if @loaded or instance_variable_defined?(:@id)
          @id = @store.send(:extract_session_id, @req)
        end

        def options
          @req.session_options
        end

        def each(&block)
          load_for_read!
          @data.each(&block)
        end

        def [](key)
          load_for_read!
          @data[key.to_s]
        end

        def fetch(key, default=Unspecified, &block)
          load_for_read!
          if default == Unspecified
            @data.fetch(key.to_s, &block)
          else
            @data.fetch(key.to_s, default, &block)
          end
        end

        def has_key?(key)
          load_for_read!
          @data.has_key?(key.to_s)
        end
        alias :key? :has_key?
        alias :include? :has_key?

        def []=(key, value)
          load_for_write!
          @data[key.to_s] = value
        end
        alias :store :[]=

        def clear
          load_for_write!
          @data.clear
        end

        def destroy
          clear
          @id = @store.send(:delete_session, @req, id, options)
        end

        def to_hash
          load_for_read!
          @data.dup
        end

        def update(hash)
          load_for_write!
          @data.update(stringify_keys(hash))
        end
        alias :merge! :update

        def replace(hash)
          load_for_write!
          @data.replace(stringify_keys(hash))
        end

        def delete(key)
          load_for_write!
          @data.delete(key.to_s)
        end

        def inspect
          if loaded?
            @data.inspect
          else
            "#<#{self.class}:0x#{self.object_id.to_s(16)} not yet loaded>"
          end
        end

        def exists?
          return @exists if instance_variable_defined?(:@exists)
          @data = {}
          @exists = @store.send(:session_exists?, @req)
        end

        def loaded?
          @loaded
        end

        def empty?
          load_for_read!
          @data.empty?
        end

        def keys
          load_for_read!
          @data.keys
        end

        def values
          load_for_read!
          @data.values
        end

      private

        def load_for_read!
          load! if !loaded? && exists?
        end

        def load_for_write!
          load! unless loaded?
        end

        def load!
          @id, session = @store.send(:load_session, @req)
          @data = stringify_keys(session)
          @loaded = true
        end

        def stringify_keys(other)
          hash = {}
          other.each do |key, value|
            hash[key.to_s] = value
          end
          hash
        end
      end

      # ID sets up a basic framework for implementing an id based sessioning
      # service. Cookies sent to the client for maintaining sessions will only
      # contain an id reference. Only #find_session and #write_session are
      # required to be overwritten.
      #
      # All parameters are optional.
      # * :key determines the name of the cookie, by default it is
      #   'rack.session'
      # * :path, :domain, :expire_after, :secure, and :httponly set the related
      #   cookie options as by Rack::Response#set_cookie
      # * :skip will not a set a cookie in the response nor update the session state
      # * :defer will not set a cookie in the response but still update the session
      #   state if it is used with a backend
      # * :renew (implementation dependent) will prompt the generation of a new
      #   session id, and migration of data to be referenced at the new id. If
      #   :defer is set, it will be overridden and the cookie will be set.
      # * :sidbits sets the number of bits in length that a generated session
      #   id will be.
      #
      # These options can be set on a per request basis, at the location of
      # <tt>env['rack.session.options']</tt>. Additionally the id of the
      # session can be found within the options hash at the key :id. It is
      # highly not recommended to change its value.
      #
      # Is Rack::Utils::Context compatible.
      #
      # Not included by default; you must require 'rack/session/abstract/id'
      # to use.

      class Persisted
        DEFAULT_OPTIONS = {
          :key =>           RACK_SESSION,
          :path =>          '/',
          :domain =>        nil,
          :expire_after =>  nil,
          :secure =>        false,
          :httponly =>      true,
          :defer =>         false,
          :renew =>         false,
          :sidbits =>       128,
          :cookie_only =>   true,
          :secure_random => ::SecureRandom
        }.freeze

        attr_reader :key, :default_options, :sid_secure

        def initialize(app, options={})
          @app = app
          @default_options = self.class::DEFAULT_OPTIONS.merge(options)
          @key = @default_options.delete(:key)
          @cookie_only = @default_options.delete(:cookie_only)
          initialize_sid
        end

        def call(env)
          context(env)
        end

        def context(env, app=@app)
          req = make_request env
          prepare_session(req)
          status, headers, body = app.call(req.env)
          res = Rack::Response::Raw.new status, headers
          commit_session(req, res)
          [status, headers, body]
        end

        private

        def make_request(env)
          Rack::Request.new env
        end

        def initialize_sid
          @sidbits = @default_options[:sidbits]
          @sid_secure = @default_options[:secure_random]
          @sid_length = @sidbits / 4
        end

        # Generate a new session id using Ruby #rand.  The size of the
        # session id is controlled by the :sidbits option.
        # Monkey patch this to use custom methods for session id generation.

        def generate_sid(secure = @sid_secure)
          if secure
            secure.hex(@sid_length)
          else
            "%0#{@sid_length}x" % Kernel.rand(2**@sidbits - 1)
          end
        rescue NotImplementedError
          generate_sid(false)
        end

        # Sets the lazy session at 'rack.session' and places options and session
        # metadata into 'rack.session.options'.

        def prepare_session(req)
          session_was               = req.get_header RACK_SESSION
          session                   = session_class.new(self, req)
          req.set_header RACK_SESSION, session
          req.set_header RACK_SESSION_OPTIONS, @default_options.dup
          session.merge! session_was if session_was
        end

        # Extracts the session id from provided cookies and passes it and the
        # environment to #find_session.

        def load_session(req)
          sid = current_session_id(req)
          sid, session = find_session(req, sid)
          [sid, session || {}]
        end

        # Extract session id from request object.

        def extract_session_id(request)
          sid = request.cookies[@key]
          sid ||= request.params[@key] unless @cookie_only
          sid
        end

        # Returns the current session id from the SessionHash.

        def current_session_id(req)
          req.get_header(RACK_SESSION).id
        end

        # Check if the session exists or not.

        def session_exists?(req)
          value = current_session_id(req)
          value && !value.empty?
        end

        # Session should be committed if it was loaded, any of specific options like :renew, :drop
        # or :expire_after was given and the security permissions match. Skips if skip is given.

        def commit_session?(req, session, options)
          if options[:skip]
            false
          else
            has_session = loaded_session?(session) || forced_session_update?(session, options)
            has_session && security_matches?(req, options)
          end
        end

        def loaded_session?(session)
          !session.is_a?(session_class) || session.loaded?
        end

        def forced_session_update?(session, options)
          force_options?(options) && session && !session.empty?
        end

        def force_options?(options)
          options.values_at(:max_age, :renew, :drop, :defer, :expire_after).any?
        end

        def security_matches?(request, options)
          return true unless options[:secure]
          request.ssl?
        end

        # Acquires the session from the environment and the session id from
        # the session options and passes them to #write_session. If successful
        # and the :defer option is not true, a cookie will be added to the
        # response with the session's id.

        def commit_session(req, res)
          session = req.get_header RACK_SESSION
          options = session.options

          if options[:drop] || options[:renew]
            session_id = delete_session(req, session.id || generate_sid, options)
            return unless session_id
          end

          return unless commit_session?(req, session, options)

          session.send(:load!) unless loaded_session?(session)
          session_id ||= session.id
          session_data = session.to_hash.delete_if { |k,v| v.nil? }

          if not data = write_session(req, session_id, session_data, options)
            req.get_header(RACK_ERRORS).puts("Warning! #{self.class.name} failed to save session. Content dropped.")
          elsif options[:defer] and not options[:renew]
            req.get_header(RACK_ERRORS).puts("Deferring cookie for #{session_id}") if $VERBOSE
          else
            cookie = Hash.new
            cookie[:value] = data
            cookie[:expires] = Time.now + options[:expire_after] if options[:expire_after]
            cookie[:expires] = Time.now + options[:max_age] if options[:max_age]
            set_cookie(req, res, cookie.merge!(options))
          end
        end
        public :commit_session

        # Sets the cookie back to the client with session id. We skip the cookie
        # setting if the value didn't change (sid is the same) or expires was given.

        def set_cookie(request, res, cookie)
          if request.cookies[@key] != cookie[:value] || cookie[:expires]
            res.set_cookie_header =
              Utils.add_cookie_to_header(res.set_cookie_header, @key, cookie)
          end
        end

        # Allow subclasses to prepare_session for different Session classes

        def session_class
          SessionHash
        end

        # All thread safety and session retrieval procedures should occur here.
        # Should return [session_id, session].
        # If nil is provided as the session id, generation of a new valid id
        # should occur within.

        def find_session(env, sid)
          raise '#find_session not implemented.'
        end

        # All thread safety and session storage procedures should occur here.
        # Must return the session id if the session was saved successfully, or
        # false if the session could not be saved.

        def write_session(req, sid, session, options)
          raise '#write_session not implemented.'
        end

        # All thread safety and session destroy procedures should occur here.
        # Should return a new session id or nil if options[:drop]

        def delete_session(req, sid, options)
          raise '#delete_session not implemented'
        end
      end

      class ID < Persisted
        def self.inherited(klass)
          k = klass.ancestors.find { |kl| kl.respond_to?(:superclass) && kl.superclass == ID }
          unless k.instance_variable_defined?(:"@_rack_warned")
            warn "#{klass} is inheriting from #{ID}.  Inheriting from #{ID} is deprecated, please inherit from #{Persisted} instead" if $VERBOSE
            k.instance_variable_set(:"@_rack_warned", true)
          end
          super
        end

        # All thread safety and session retrieval procedures should occur here.
        # Should return [session_id, session].
        # If nil is provided as the session id, generation of a new valid id
        # should occur within.

        def find_session(req, sid)
          get_session req.env, sid
        end

        # All thread safety and session storage procedures should occur here.
        # Must return the session id if the session was saved successfully, or
        # false if the session could not be saved.

        def write_session(req, sid, session, options)
          set_session req.env, sid, session, options
        end

        # All thread safety and session destroy procedures should occur here.
        # Should return a new session id or nil if options[:drop]

        def delete_session(req, sid, options)
          destroy_session req.env, sid, options
        end
      end
    end
  end
end
