class Premailer
  module Rails
    class CustomizedPremailer < ::Premailer
      def initialize(html)
        # In order to pass the CSS as string to super it is necessary to access
        # the parsed HTML beforehand. To do so, the adapter needs to be
        # initialized. The ::Premailer::Adapter handles the discovery of
        # a suitable adapter. To make load_html work, an adapter needs to be
        # included and @options[:with_html_string] needs to be set. For further
        # information, refer to ::Premailer#initialize.
        @options = Rails.config.merge(with_html_string: true)
        Premailer.send(:include, Adapter.find(Adapter.use))
        doc = load_html(html)
        options = @options.merge(css_string: CSSHelper.css_for_doc(doc))

        super(doc.to_s, options)
      end
    end
  end
end
