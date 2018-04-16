class Premailer
  module Rails
    module CSSHelper
      extend self

      FileNotFound = Class.new(StandardError)

      attr_accessor :cache
      self.cache = {}

      # Returns all linked CSS files concatenated as string.
      def css_for_doc(doc)
        css_urls_in_doc(doc).map { |url| css_for_url(url) }.join("\n")
      end

      def css_for_url(url)
        if cache_enabled?
          load_css_with_cache(url)
        else
          load_css(url)
        end
      end

      private

      def css_urls_in_doc(doc)
        doc.search('link[@rel="stylesheet"]:not([@data-premailer="ignore"])').map do |link|
          if link.respond_to?(:remove)
            link.remove
          else
            link.parent.children.delete(link)
          end
          link.attributes['href'].to_s
        end
      end

      def load_css_with_cache(url)
        self.cache[url] ||= load_css(url)
      end

      def cache_enabled?
        defined?(::Rails) && ::Rails.env.production?
      end

      def load_css(url)
        Premailer::Rails.config.fetch(:strategies).each do |strategy|
          css = find_strategy(strategy).load(url)
          return css.force_encoding('UTF-8') if css
        end

        raise FileNotFound, %{File with URL "#{url}" could not be loaded by any strategy.}
      end

      def find_strategy(key)
        case key
        when :filesystem
          CSSLoaders::FileSystemLoader
        when :asset_pipeline
          CSSLoaders::AssetPipelineLoader
        when :network
          CSSLoaders::NetworkLoader
        else
          key
        end
      end
    end
  end
end
