# frozen_string_literal: true
require 'uri'
require 'set'
require 'yaml'
require 'cgi'

module Sidekiq
  # This is not a public API
  module WebHelpers
    def strings(lang)
      @@strings ||= {}
      @@strings[lang] ||= begin
        # Allow sidekiq-web extensions to add locale paths
        # so extensions can be localized
        settings.locales.each_with_object({}) do |path, global|
          find_locale_files(lang).each do |file|
            strs = YAML.load(File.open(file))
            global.merge!(strs[lang])
          end
        end
      end
    end

    def clear_caches
      @@strings = nil
      @@locale_files = nil
      @@available_locales = nil
    end

    def locale_files
      @@locale_files ||= settings.locales.flat_map do |path|
        Dir["#{path}/*.yml"]
      end
    end

    def available_locales
      @@available_locales ||= locale_files.map { |path| File.basename(path, '.yml') }.uniq
    end

    def find_locale_files(lang)
      locale_files.select { |file| file =~ /\/#{lang}\.yml$/ }
    end

    # This is a hook for a Sidekiq Pro feature.  Please don't touch.
    def filtering(*)
    end

    # This view helper provide ability display you html code in
    # to head of page. Example:
    #
    #   <% add_to_head do %>
    #     <link rel="stylesheet" .../>
    #     <meta .../>
    #   <% end %>
    #
    def add_to_head
      @head_html ||= []
      @head_html << yield.dup if block_given?
    end

    def display_custom_head
      @head_html.join if defined?(@head_html)
    end

    def poll_path
      if current_path != '' && params['poll']
        root_path + current_path
      else
        ""
      end
    end

    def text_direction
      get_locale['TextDirection'] || 'ltr'
    end

    def rtl?
      text_direction == 'rtl'
    end

    # See https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4
    def user_preferred_languages
      languages = env['HTTP_ACCEPT_LANGUAGE']
      languages.to_s.downcase.gsub(/\s+/, '').split(',').map do |language|
        locale, quality = language.split(';q=', 2)
        locale  = nil if locale == '*' # Ignore wildcards
        quality = quality ? quality.to_f : 1.0
        [locale, quality]
      end.sort do |(_, left), (_, right)|
        right <=> left
      end.map(&:first).compact
    end

    # Given an Accept-Language header like "fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4,ru;q=0.2"
    # this method will try to best match the available locales to the user's preferred languages.
    #
    # Inspiration taken from https://github.com/iain/http_accept_language/blob/master/lib/http_accept_language/parser.rb
    def locale
      @locale ||= begin
        matched_locale = user_preferred_languages.map do |preferred|
          preferred_language = preferred.split('-', 2).first

          lang_group = available_locales.select do |available|
            preferred_language == available.split('-', 2).first
          end

          lang_group.find { |lang| lang == preferred } || lang_group.min_by(&:length)
        end.compact.first

        matched_locale || 'en'
      end
    end

    # mperham/sidekiq#3243
    def unfiltered?
      yield unless env['PATH_INFO'].start_with?("/filter/")
    end

    def get_locale
      strings(locale)
    end

    def t(msg, options={})
      string = get_locale[msg] || msg
      if options.empty?
        string
      else
        string % options
      end
    end

    def workers
      @workers ||= Sidekiq::Workers.new
    end

    def processes
      @processes ||= Sidekiq::ProcessSet.new
    end

    def stats
      @stats ||= Sidekiq::Stats.new
    end

    def retries_with_score(score)
      Sidekiq.redis do |conn|
        conn.zrangebyscore('retry', score, score)
      end.map { |msg| Sidekiq.load_json(msg) }
    end

    def redis_connection
      Sidekiq.redis do |conn|
        c = conn.connection
        "redis://#{c[:location]}/#{c[:db]}"
      end
    end

    def namespace
      @@ns ||= Sidekiq.redis { |conn| conn.respond_to?(:namespace) ? conn.namespace : nil }
    end

    def redis_info
      Sidekiq.redis_info
    end

    def root_path
      "#{env['SCRIPT_NAME']}/"
    end

    def current_path
      @current_path ||= request.path_info.gsub(/^\//,'')
    end

    def current_status
      workers.size == 0 ? 'idle' : 'active'
    end

    def relative_time(time)
      stamp = time.getutc.iso8601
      %{<time class="ltr" dir="ltr" title="#{stamp}" datetime="#{stamp}">#{time}</time>}
    end

    def job_params(job, score)
      "#{score}-#{job['jid']}"
    end

    def parse_params(params)
      score, jid = params.split("-")
      [score.to_f, jid]
    end

    SAFE_QPARAMS = %w(page poll)

    # Merge options with current params, filter safe params, and stringify to query string
    def qparams(options)
      # stringify
      options.keys.each do |key|
        options[key.to_s] = options.delete(key)
      end

      params.merge(options).map do |key, value|
        SAFE_QPARAMS.include?(key) ? "#{key}=#{CGI.escape(value.to_s)}" : next
      end.compact.join("&")
    end

    def truncate(text, truncate_after_chars = 2000)
      truncate_after_chars && text.size > truncate_after_chars ? "#{text[0..truncate_after_chars]}..." : text
    end

    def display_args(args, truncate_after_chars = 2000)
      args.map do |arg|
        h(truncate(to_display(arg), truncate_after_chars))
      end.join(", ")
    end

    def csrf_tag
      "<input type='hidden' name='authenticity_token' value='#{session[:csrf]}'/>"
    end

    def to_display(arg)
      begin
        arg.inspect
      rescue
        begin
          arg.to_s
        rescue => ex
          "Cannot display argument: [#{ex.class.name}] #{ex.message}"
        end
      end
    end

    RETRY_JOB_KEYS = Set.new(%w(
      queue class args retry_count retried_at failed_at
      jid error_message error_class backtrace
      error_backtrace enqueued_at retry wrapped
      created_at
    ))

    def retry_extra_items(retry_job)
      @retry_extra_items ||= {}.tap do |extra|
        retry_job.item.each do |key, value|
          extra[key] = value unless RETRY_JOB_KEYS.include?(key)
        end
      end
    end

    def number_with_delimiter(number)
      begin
        Float(number)
      rescue ArgumentError, TypeError
        return number
      end

      options = {delimiter: ',', separator: '.'}
      parts = number.to_s.to_str.split('.')
      parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{options[:delimiter]}")
      parts.join(options[:separator])
    end

    def h(text)
      ::Rack::Utils.escape_html(text)
    rescue ArgumentError => e
      raise unless e.message.eql?('invalid byte sequence in UTF-8')
      text.encode!('UTF-16', 'UTF-8', invalid: :replace, replace: '').encode!('UTF-8', 'UTF-16')
      retry
    end

    # Any paginated list that performs an action needs to redirect
    # back to the proper page after performing that action.
    def redirect_with_query(url)
      r = request.referer
      if r && r =~ /\?/
        ref = URI(r)
        redirect("#{url}?#{ref.query}")
      else
        redirect url
      end
    end

    def environment_title_prefix
      environment = Sidekiq.options[:environment] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'

      "[#{environment.upcase}] " unless environment == "production"
    end

    def product_version
      "Sidekiq v#{Sidekiq::VERSION}"
    end

    def server_utc_time
      Time.now.utc.strftime('%H:%M:%S UTC')
    end

    def redis_connection_and_namespace
      @redis_connection_and_namespace ||= begin
        namespace_suffix = namespace == nil ? '' : "##{namespace}"
        "#{redis_connection}#{namespace_suffix}"
      end
    end

    def retry_or_delete_or_kill(job, params)
      if params['retry']
        job.retry
      elsif params['delete']
        job.delete
      elsif params['kill']
        job.kill
      end
    end

    def delete_or_add_queue(job, params)
      if params['delete']
        job.delete
      elsif params['add_to_queue']
        job.add_to_queue
      end
    end
  end
end
