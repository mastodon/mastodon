# frozen_string_literal: true

module Mcaptcha
  module Helpers
    DEFAULT_ERRORS = {
      mcaptcha_unreachable: 'Oops, we failed to validate your mCaptcha response. Please try again.',
      verification_failed: 'mCaptcha verification failed, please try again.'
    }.freeze
    DEFAULT_OPTIONS = {
      external_script: true,
      script: true,
      script_async: true,
      script_defer: true,
      theme: :dark
    }.freeze

    def self.mcaptcha(options)
      # TODO: understand if `Secure Token` and `SSL` options are relevant for mCaptcha
      if options.key?(:stoken)
        raise(McaptchaError, "Secure Token is deprecated. Please remove 'stoken' from your calls to mcaptcha_tags.")
      end
      if options.key?(:ssl)
        raise(McaptchaError, "SSL is now always true. Please remove 'ssl' from your calls to mcaptcha_tags.")
      end

      html = generate_tags(options)
      # rubocop:disable Rails/OutputSafety
      html.respond_to?(:html_safe) ? html.html_safe : html
      # rubocop:enable Rails/OutputSafety
    end

    def self.to_error_message(key)
      default = DEFAULT_ERRORS.fetch(key) { raise ArgumentError "Unknown mCaptcha error - #{key}" }
      to_message("mcaptcha.errors.#{key}", default)
    end

    if defined?(I18n)
      def self.to_message(key, default)
        I18n.translate(key, default: default)
      end
    else
      def self.to_message(_key, default)
        default
      end
    end

    private_class_method def self.generate_tags(options)
      options = options.dup
      DEFAULT_OPTIONS.each do |name, value|
        options[name] = value unless options.key?(name)
      end
      generate_script_tag(options) + generate_placeholder_tag(options)
    end

    private_class_method def self.generate_script_tag(options)
      # Forge script URL
      url = Mcaptcha.configuration.api_server_url
      query_params = hash_to_query(
        hl: options.delete(:hl),
        onload: options.delete(:onload),
        recaptchacompat: options.delete(:recaptchacompat),
        render: options.delete(:render)
      )
      url += "?#{query_params}" unless query_params.empty?

      # Forge additional attributes
      nonce = options.delete(:nonce)
      nonce_attr = " nonce='#{nonce}'" if nonce
      async_attr = "async" if options.delete(:script_async)
      defer_attr = "defer" if options.delete(:script_defer)
      additional_attributes = [async_attr, defer_attr, nonce_attr].compact.join(" ")

      return "" if options.delete(:script) == false || options.delete(:external_script) == false

      %(<script src="#{url}" #{additional_attributes}></script>)
    end

    private_class_method def self.generate_placeholder_tag(options)
      attributes = {}

      # Forge data-* attributes
      %i[
        callback close_callback error_callback chalexpired_callback
        expired_callback open_callback size tabindex theme
      ].each do |data_attribute|
        value = options.delete(data_attribute)
        attributes["data-#{data_attribute.to_s.tr('_', '-')}"] = value if value
      end
      attributes["data-sitekey"] = options.delete(:site_key) || Mcaptcha.configuration.site_key!

      # Forge CSS classes
      attributes["class"] = "m-captcha #{options.delete(:class)}"

      # Remaining options will be added as attributes on the tag.
      %(<div #{html_attributes(attributes)} #{html_attributes(options)}></div>)
    end

    private_class_method def self.hash_to_query(hash)
      hash.delete_if { |_, val| val.nil? || val.empty? }.to_a.map { |pair| pair.join('=') }.join('&')
    end

    private_class_method def self.html_attributes(hash)
      hash.map { |k, v| %(#{k}="#{v}") }.join(" ")
    end
  end
end
