# frozen_string_literal: true
module Kaminari
  module Helpers
    PARAM_KEY_BLACKLIST = [:authenticity_token, :commit, :utf8, :_method, :script_name].freeze

    # A tag stands for an HTML tag inside the paginator.
    # Basically, a tag has its own partial template file, so every tag can be
    # rendered into String using its partial template.
    #
    # The template file should be placed in your app/views/kaminari/ directory
    # with underscored class name (besides the "Tag" class. Tag is an abstract
    # class, so _tag partial is not needed).
    #   e.g.)  PrevLink  ->  app/views/kaminari/_prev_link.html.erb
    #
    # When no matching template were found in your app, the engine's pre
    # installed template will be used.
    #   e.g.)  Paginator  ->  $GEM_HOME/kaminari-x.x.x/app/views/kaminari/_paginator.html.erb
    class Tag
      def initialize(template, params: {}, param_name: nil, theme: nil, views_prefix: nil, **options) #:nodoc:
        @template, @theme, @views_prefix, @options = template, theme, views_prefix, options
        @param_name = param_name || Kaminari.config.param_name
        @params = template.params
        # @params in Rails 5 no longer inherits from Hash
        @params = @params.to_unsafe_h if @params.respond_to?(:to_unsafe_h)
        @params = @params.with_indifferent_access
        @params.except!(*PARAM_KEY_BLACKLIST)
        @params.merge! params
      end

      def to_s(locals = {}) #:nodoc:
        formats = (@template.respond_to?(:formats) ? @template.formats : Array(@template.params[:format])) + [:html]
        @template.render partial: partial_path, locals: @options.merge(locals), formats: formats
      end

      def page_url_for(page)
        params = params_for(page)
        params[:only_path] = true
        @template.url_for params
      end

      private

      def params_for(page)
        page_params = Rack::Utils.parse_nested_query("#{@param_name}=#{page}")
        page_params = @params.deep_merge(page_params)

        if !Kaminari.config.params_on_first_page && (page <= 1)
          # This converts a hash:
          #   from: {other: "params", page: 1}
          #     to: {other: "params", page: nil}
          #   (when @param_name == "page")
          #
          #   from: {other: "params", user: {name: "yuki", page: 1}}
          #     to: {other: "params", user: {name: "yuki", page: nil}}
          #   (when @param_name == "user[page]")
          @param_name.to_s.scan(/[\w\.]+/)[0..-2].inject(page_params){|h, k| h[k] }[$&] = nil
        end

        page_params
      end

      def partial_path
        [
         @views_prefix,
         "kaminari",
         @theme,
         self.class.name.demodulize.underscore
        ].compact.join("/")
      end
    end

    # Tag that contains a link
    module Link
      # target page number
      def page
        raise 'Override page with the actual page value to be a Page.'
      end
      # the link's href
      def url
        page_url_for page
      end
      def to_s(locals = {}) #:nodoc:
        locals[:url] = url
        super locals
      end
    end

    # A page
    class Page < Tag
      include Link
      # target page number
      def page
        @options[:page]
      end
      def to_s(locals = {}) #:nodoc:
        locals[:page] = page
        super locals
      end
    end

    # Link with page number that appears at the leftmost
    class FirstPage < Tag
      include Link
      def page #:nodoc:
        1
      end
    end

    # Link with page number that appears at the rightmost
    class LastPage < Tag
      include Link
      def page #:nodoc:
        @options[:total_pages]
      end
    end

    # The "previous" page of the current page
    class PrevPage < Tag
      include Link

      # TODO: Remove this initializer before 1.3.0.
      def initialize(template, params: {}, param_name: nil, theme: nil, views_prefix: nil, **options) #:nodoc:
        # params in Rails 5 may not be a Hash either,
        # so it must be converted to a Hash to be merged into @params
        if params && params.respond_to?(:to_unsafe_h)
          ActiveSupport::Deprecation.warn 'Explicitly passing params to helpers could be omitted.'
          params = params.to_unsafe_h
        end

        super(template, params: params, param_name: param_name, theme: theme, views_prefix: views_prefix, **options)
      end

      def page #:nodoc:
        @options[:current_page] - 1
      end
    end

    # The "next" page of the current page
    class NextPage < Tag
      include Link

      # TODO: Remove this initializer before 1.3.0.
      def initialize(template, params: {}, param_name: nil, theme: nil, views_prefix: nil, **options) #:nodoc:
        # params in Rails 5 may not be a Hash either,
        # so it must be converted to a Hash to be merged into @params
        if params && params.respond_to?(:to_unsafe_h)
          ActiveSupport::Deprecation.warn 'Explicitly passing params to helpers could be omitted.'
          params = params.to_unsafe_h
        end

        super(template, params: params, param_name: param_name, theme: theme, views_prefix: views_prefix, **options)
      end

      def page #:nodoc:
        @options[:current_page] + 1
      end
    end

    # Non-link tag that stands for skipped pages...
    class Gap < Tag
    end
  end
end
