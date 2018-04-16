require 'omniauth/key_store'

module OmniAuth
  class NoSessionError < StandardError; end
  # The Strategy is the base unit of OmniAuth's ability to
  # wrangle multiple providers. Each strategy provided by
  # OmniAuth includes this mixin to gain the default functionality
  # necessary to be compatible with the OmniAuth library.
  module Strategy # rubocop:disable ModuleLength
    def self.included(base)
      OmniAuth.strategies << base

      base.extend ClassMethods
      base.class_eval do
        option :setup, false
        option :skip_info, false
        option :origin_param, 'origin'
      end
    end

    module ClassMethods
      # Returns an inherited set of default options set at the class-level
      # for each strategy.
      def default_options
        # existing = superclass.default_options if superclass.respond_to?(:default_options)
        existing = superclass.respond_to?(:default_options) ? superclass.default_options : {}
        @default_options ||= OmniAuth::Strategy::Options.new(existing)
      end

      # This allows for more declarative subclassing of strategies by allowing
      # default options to be set using a simple configure call.
      #
      # @param options [Hash] If supplied, these will be the default options (deep-merged into the superclass's default options).
      # @yield [Options] The options Mash that allows you to set your defaults as you'd like.
      #
      # @example Using a yield to configure the default options.
      #
      #   class MyStrategy
      #     include OmniAuth::Strategy
      #
      #     configure do |c|
      #       c.foo = 'bar'
      #     end
      #   end
      #
      # @example Using a hash to configure the default options.
      #
      #   class MyStrategy
      #     include OmniAuth::Strategy
      #     configure foo: 'bar'
      #   end
      def configure(options = nil)
        if block_given?
          yield default_options
        else
          default_options.deep_merge!(options)
        end
      end

      # Directly declare a default option for your class. This is a useful from
      # a documentation perspective as it provides a simple line-by-line analysis
      # of the kinds of options your strategy provides by default.
      #
      # @param name [Symbol] The key of the default option in your configuration hash.
      # @param value [Object] The value your object defaults to. Nil if not provided.
      #
      # @example
      #
      #   class MyStrategy
      #     include OmniAuth::Strategy
      #
      #     option :foo, 'bar'
      #     option
      #   end
      def option(name, value = nil)
        default_options[name] = value
      end

      # Sets (and retrieves) option key names for initializer arguments to be
      # recorded as. This takes care of 90% of the use cases for overriding
      # the initializer in OmniAuth Strategies.
      def args(args = nil)
        if args
          @args = Array(args)
          return
        end
        existing = superclass.respond_to?(:args) ? superclass.args : []
        (instance_variable_defined?(:@args) && @args) || existing
      end

      %w[uid info extra credentials].each do |fetcher|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          attr_reader :#{fetcher}_proc
          private :#{fetcher}_proc

          def #{fetcher}(&block)
            return #{fetcher}_proc unless block_given?
            @#{fetcher}_proc = block
          end

          def #{fetcher}_stack(context)
            compile_stack(self.ancestors, :#{fetcher}, context)
          end
        RUBY
      end

      def compile_stack(ancestors, method, context)
        stack = ancestors.inject([]) do |a, ancestor|
          a << context.instance_eval(&ancestor.send(method)) if ancestor.respond_to?(method) && ancestor.send(method)
          a
        end
        stack.reverse!
      end
    end

    attr_reader :app, :env, :options, :response

    # Initializes the strategy by passing in the Rack endpoint,
    # the unique URL segment name for this strategy, and any
    # additional arguments. An `options` hash is automatically
    # created from the last argument if it is a hash.
    #
    # @param app [Rack application] The application on which this middleware is applied.
    #
    # @overload new(app, options = {})
    #   If nothing but a hash is supplied, initialized with the supplied options
    #   overriding the strategy's default options via a deep merge.
    # @overload new(app, *args, options = {})
    #   If the strategy has supplied custom arguments that it accepts, they may
    #   will be passed through and set to the appropriate values.
    #
    # @yield [Options] Yields options to block for further configuration.
    def initialize(app, *args, &block) # rubocop:disable UnusedMethodArgument
      @app = app
      @env = nil
      @options = self.class.default_options.dup

      options.deep_merge!(args.pop) if args.last.is_a?(Hash)
      options[:name] ||= self.class.to_s.split('::').last.downcase

      self.class.args.each do |arg|
        break if args.empty?
        options[arg] = args.shift
      end

      # Make sure that all of the args have been dealt with, otherwise error out.
      raise(ArgumentError.new("Received wrong number of arguments. #{args.inspect}")) unless args.empty?

      yield options if block_given?
    end

    def inspect
      "#<#{self.class}>"
    end

    # Direct access to the OmniAuth logger, automatically prefixed
    # with this strategy's name.
    #
    # @example
    #   log :warn, "This is a warning."
    def log(level, message)
      OmniAuth.logger.send(level, "(#{name}) #{message}")
    end

    # Duplicates this instance and runs #call! on it.
    # @param [Hash] The Rack environment.
    def call(env)
      dup.call!(env)
    end

    # The logic for dispatching any additional actions that need
    # to be taken. For instance, calling the request phase if
    # the request path is recognized.
    #
    # @param env [Hash] The Rack environment.
    def call!(env) # rubocop:disable CyclomaticComplexity, PerceivedComplexity
      unless env['rack.session']
        error = OmniAuth::NoSessionError.new('You must provide a session to use OmniAuth.')
        raise(error)
      end

      @env = env
      @env['omniauth.strategy'] = self if on_auth_path?

      return mock_call!(env) if OmniAuth.config.test_mode
      return options_call if on_auth_path? && options_request?
      return request_call if on_request_path? && OmniAuth.config.allowed_request_methods.include?(request.request_method.downcase.to_sym)
      return callback_call if on_callback_path?
      return other_phase if respond_to?(:other_phase)
      @app.call(env)
    end

    # Responds to an OPTIONS request.
    def options_call
      OmniAuth.config.before_options_phase.call(env) if OmniAuth.config.before_options_phase
      verbs = OmniAuth.config.allowed_request_methods.collect(&:to_s).collect(&:upcase).join(', ')
      [200, {'Allow' => verbs}, []]
    end

    # Performs the steps necessary to run the request phase of a strategy.
    def request_call # rubocop:disable CyclomaticComplexity, MethodLength, PerceivedComplexity
      setup_phase
      log :info, 'Request phase initiated.'

      # store query params from the request url, extracted in the callback_phase
      session['omniauth.params'] = request.GET
      OmniAuth.config.before_request_phase.call(env) if OmniAuth.config.before_request_phase

      if options.form.respond_to?(:call)
        log :info, 'Rendering form from supplied Rack endpoint.'
        options.form.call(env)
      elsif options.form
        log :info, 'Rendering form from underlying application.'
        call_app!
      elsif !options.origin_param
        request_phase
      else
        if request.params[options.origin_param]
          env['rack.session']['omniauth.origin'] = request.params[options.origin_param]
        elsif env['HTTP_REFERER'] && !env['HTTP_REFERER'].match(/#{request_path}$/)
          env['rack.session']['omniauth.origin'] = env['HTTP_REFERER']
        end

        request_phase
      end
    end

    # Performs the steps necessary to run the callback phase of a strategy.
    def callback_call
      setup_phase
      log :info, 'Callback phase initiated.'
      @env['omniauth.origin'] = session.delete('omniauth.origin')
      @env['omniauth.origin'] = nil if env['omniauth.origin'] == ''
      @env['omniauth.params'] = session.delete('omniauth.params') || {}
      OmniAuth.config.before_callback_phase.call(@env) if OmniAuth.config.before_callback_phase
      callback_phase
    end

    # Returns true if the environment recognizes either the
    # request or callback path.
    def on_auth_path?
      on_request_path? || on_callback_path?
    end

    def on_request_path?
      if options[:request_path].respond_to?(:call)
        options[:request_path].call(env)
      else
        on_path?(request_path)
      end
    end

    def on_callback_path?
      on_path?(callback_path)
    end

    def on_path?(path)
      current_path.casecmp(path).zero?
    end

    def options_request?
      request.request_method == 'OPTIONS'
    end

    # This is called in lieu of the normal request process
    # in the event that OmniAuth has been configured to be
    # in test mode.
    def mock_call!(*)
      return mock_request_call if on_request_path? && OmniAuth.config.allowed_request_methods.include?(request.request_method.downcase.to_sym)
      return mock_callback_call if on_callback_path?
      call_app!
    end

    def mock_request_call
      setup_phase

      session['omniauth.params'] = request.GET
      OmniAuth.config.before_request_phase.call(env) if OmniAuth.config.before_request_phase
      if options.origin_param
        if request.params[options.origin_param]
          session['omniauth.origin'] = request.params[options.origin_param]
        elsif env['HTTP_REFERER'] && !env['HTTP_REFERER'].match(/#{request_path}$/)
          session['omniauth.origin'] = env['HTTP_REFERER']
        end
      end

      redirect(callback_url)
    end

    def mock_callback_call
      setup_phase
      @env['omniauth.origin'] = session.delete('omniauth.origin')
      @env['omniauth.origin'] = nil if env['omniauth.origin'] == ''
      @env['omniauth.params'] = session.delete('omniauth.params') || {}

      mocked_auth = OmniAuth.mock_auth_for(name.to_s)
      if mocked_auth.is_a?(Symbol)
        fail!(mocked_auth)
      else
        @env['omniauth.auth'] = mocked_auth
        OmniAuth.config.before_callback_phase.call(@env) if OmniAuth.config.before_callback_phase
        call_app!
      end
    end

    # The setup phase looks for the `:setup` option to exist and,
    # if it is, will call either the Rack endpoint supplied to the
    # `:setup` option or it will call out to the setup path of the
    # underlying application. This will default to `/auth/:provider/setup`.
    def setup_phase
      if options[:setup].respond_to?(:call)
        log :info, 'Setup endpoint detected, running now.'
        options[:setup].call(env)
      elsif options[:setup]
        log :info, 'Calling through to underlying application for setup.'
        setup_env = env.merge('PATH_INFO' => setup_path, 'REQUEST_METHOD' => 'GET')
        call_app!(setup_env)
      end
    end

    # @abstract This method is called when the user is on the request path. You should
    # perform any information gathering you need to be able to authenticate
    # the user in this phase.
    def request_phase
      raise(NotImplementedError)
    end

    def uid
      self.class.uid_stack(self).last
    end

    def info
      merge_stack(self.class.info_stack(self))
    end

    def credentials
      merge_stack(self.class.credentials_stack(self))
    end

    def extra
      merge_stack(self.class.extra_stack(self))
    end

    def auth_hash
      hash = AuthHash.new(:provider => name, :uid => uid)
      hash.info = info unless skip_info?
      hash.credentials = credentials if credentials
      hash.extra = extra if extra
      hash
    end

    # Determines whether or not user info should be retrieved. This
    # allows some strategies to save a call to an external API service
    # for existing users. You can use it either by setting the `:skip_info`
    # to true or by setting `:skip_info` to a Proc that takes a uid and
    # evaluates to true when you would like to skip info.
    #
    # @example
    #
    #   use MyStrategy, :skip_info => lambda{|uid| User.find_by_uid(uid)}
    def skip_info?
      return false unless options.skip_info?
      return true unless options.skip_info.respond_to?(:call)
      options.skip_info.call(uid)
    end

    def callback_phase
      env['omniauth.auth'] = auth_hash
      call_app!
    end

    def path_prefix
      options[:path_prefix] || OmniAuth.config.path_prefix
    end

    def custom_path(kind)
      if options[kind].respond_to?(:call)
        result = options[kind].call(env)
        return nil unless result.is_a?(String)
        result
      else
        options[kind]
      end
    end

    def request_path
      @request_path ||= options[:request_path].is_a?(String) ? options[:request_path] : "#{path_prefix}/#{name}"
    end

    def callback_path
      @callback_path ||= begin
        path = options[:callback_path] if options[:callback_path].is_a?(String)
        path ||= current_path if options[:callback_path].respond_to?(:call) && options[:callback_path].call(env)
        path ||= custom_path(:request_path)
        path ||= "#{path_prefix}/#{name}/callback"
        path
      end
    end

    def setup_path
      options[:setup_path] || "#{path_prefix}/#{name}/setup"
    end

    CURRENT_PATH_REGEX = %r{/$}
    EMPTY_STRING       = ''.freeze
    def current_path
      @current_path ||= request.path_info.downcase.sub(CURRENT_PATH_REGEX, EMPTY_STRING)
    end

    def query_string
      request.query_string.empty? ? '' : "?#{request.query_string}"
    end

    def call_app!(env = @env)
      @app.call(env)
    end

    def full_host
      case OmniAuth.config.full_host
      when String
        OmniAuth.config.full_host
      when Proc
        OmniAuth.config.full_host.call(env)
      else
        # in Rack 1.3.x, request.url explodes if scheme is nil
        if request.scheme && request.url.match(URI::ABS_URI)
          uri = URI.parse(request.url.gsub(/\?.*$/, ''))
          uri.path = ''
          # sometimes the url is actually showing http inside rails because the
          # other layers (like nginx) have handled the ssl termination.
          uri.scheme = 'https' if ssl? # rubocop:disable BlockNesting
          uri.to_s
        else ''
        end
      end
    end

    def callback_url
      full_host + script_name + callback_path + query_string
    end

    def script_name
      @env['SCRIPT_NAME'] || ''
    end

    def session
      @env['rack.session']
    end

    def request
      @request ||= Rack::Request.new(@env)
    end

    def name
      options[:name]
    end

    def redirect(uri)
      r = Rack::Response.new

      if options[:iframe]
        r.write("<script type='text/javascript' charset='utf-8'>top.location.href = '#{uri}';</script>")
      else
        r.write("Redirecting to #{uri}...")
        r.redirect(uri)
      end

      r.finish
    end

    def user_info
      {}
    end

    def fail!(message_key, exception = nil)
      env['omniauth.error'] = exception
      env['omniauth.error.type'] = message_key.to_sym
      env['omniauth.error.strategy'] = self

      if exception
        log :error, "Authentication failure! #{message_key}: #{exception.class}, #{exception.message}"
      else
        log :error, "Authentication failure! #{message_key} encountered."
      end

      OmniAuth.config.on_failure.call(env)
    end

    def dup
      super.tap do
        @options = @options.dup
      end
    end

    class Options < OmniAuth::KeyStore; end

  protected

    def merge_stack(stack)
      stack.inject({}) do |a, e|
        a.merge!(e)
        a
      end
    end

    def ssl?
      request.env['HTTPS'] == 'on' ||
        request.env['HTTP_X_FORWARDED_SSL'] == 'on' ||
        request.env['HTTP_X_FORWARDED_SCHEME'] == 'https' ||
        (request.env['HTTP_X_FORWARDED_PROTO'] && request.env['HTTP_X_FORWARDED_PROTO'].split(',')[0] == 'https') ||
        request.env['rack.url_scheme'] == 'https'
    end
  end
end
