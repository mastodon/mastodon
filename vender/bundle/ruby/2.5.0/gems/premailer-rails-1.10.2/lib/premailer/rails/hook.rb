class Premailer
  module Rails
    class Hook
      attr_reader :message

      class << self
        def perform(message)
          new(message).perform
          message
        end

        alias_method :delivering_email, :perform
        alias_method :previewing_email, :perform
      end

      def initialize(message)
        @message = message
      end

      def perform
        if skip_premailer_header_present?
          remove_skip_premailer_header
        elsif message_contains_html?
          replace_html_part(generate_html_part_replacement)
        end
      end

      private

      def skip_premailer_header_present?
        message.header[:skip_premailer]
      end

      def remove_skip_premailer_header
        message.header[:skip_premailer] = nil
      end

      def message_contains_html?
        html_part.present?
      end

      # Returns true if the message itself has a content type of text/html, thus
      # it does not contain other parts such as alternatives and attachments.
      def pure_html_message?
        message.content_type && message.content_type.include?('text/html')
      end

      def generate_html_part_replacement
        if generate_text_part?
          generate_alternative_part
        else
          generate_html_part
        end
      end

      def generate_text_part?
        Rails.config[:generate_text_part] && !message.text_part
      end

      def generate_alternative_part
        part = Mail::Part.new(content_type: 'multipart/alternative')
        part.add_part(generate_text_part)
        part.add_part(generate_html_part)

        part
      end

      def generate_html_part
        # Make sure that the text part is generated first. Otherwise the text
        # can end up containing CSS rules.
        generate_text_part if generate_text_part?

        part = html_part
        html = premailer.to_inline_css
        Mail::Part.new do
          content_transfer_encoding part.content_transfer_encoding
          content_type "text/html; charset=#{part.charset}"
          body html
          body_encoding part.body.encoding
        end
      end

      def generate_text_part
        @text_part ||= begin
          part = html_part
          text = premailer.to_plain_text
          Mail::Part.new do
            content_transfer_encoding part.content_transfer_encoding
            content_type "text/plain; charset=#{part.charset}"
            body text
            body_encoding part.body.encoding
          end
        end
      end

      def premailer
        @premailer ||= CustomizedPremailer.new(html_part.decoded)
      end

      def html_part
        if pure_html_message?
          message
        else
          message.html_part
        end
      end

      def replace_html_part(new_part)
        if pure_html_message?
          replace_in_pure_html_message(new_part)
        else
          replace_part_in_list(message.parts, html_part, new_part)
        end
      end

      # If the new part is a pure text/html part, the body and its content type
      # are used for the message. If the new part is
      def replace_in_pure_html_message(new_part)
        if new_part.content_type.include?('text/html')
          message.body = new_part.decoded
          message.content_type = new_part.content_type
        else
          message.body = nil
          message.content_type = new_part.content_type
          new_part.parts.each do |part|
            message.add_part(part)
          end
        end
      end

      def replace_part_in_list(parts_list, old_part, new_part)
        if (index = parts_list.index(old_part))
          parts_list[index] = new_part
        else
          parts_list.any? do |part|
            if part.respond_to?(:parts)
              replace_part_in_list(part.parts, old_part, new_part)
            end
          end
        end
      end
    end
  end
end
