# coding: utf-8

require 'mail'

module Fixtures
  module Message
    extend self

    HTML_PART = <<-HTML
<html>
  <head>
  </head>
  <body>
    <p>
      Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
      tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim
      veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea
      commodo consequat.
    </p>
  </body>
</html>
    HTML

    UNICODE_STRING = '٩(-̮̮̃-̃)۶ ٩(●̮̮̃•̃)۶ ٩(͡๏̯͡๏)۶ ٩(-̮̮̃•̃).'

    HTML_PART_WITH_UNICODE = <<-HTML
<html>
  <head>
  </head>
  <body>
    <p>
      #{UNICODE_STRING}
    </p>
  </body>
</html>
    HTML

    HTML_PART_WITH_CSS = <<-HTML
<html>
  <head>
    <style type="text/css">
      p { color: red; }
    </style>
  </head>
  <body>
    <p>
      Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod
      tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim
      veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea
      commodo consequat.
    </p>
  </body>
</html>
    HTML

    TEXT_PART = <<-TEXT
Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor
incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis
nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
    TEXT

    def with_parts(*part_types)
      if part_types.count == 1 and [:html, :text].include?(part_types.first)
        return with_body(part_types.first)
      end

      message = base_message
      content_part = message

      if part_types.include?(:html) and part_types.include?(:text)
        content_part = Mail::Part.new(content_type: 'multipart/alternative')
        message.add_part(content_part)
      end

      if part_types.include? :html
        html_part = Mail::Part.new do
          body HTML_PART_WITH_CSS
          content_type 'text/html; charset=UTF-8'
        end
        content_part.html_part = html_part
      end

      if part_types.include? :text
        text_part = Mail::Part.new do
          body TEXT_PART
          content_type 'text/plain; charset=UTF-8'
        end
        content_part.text_part = text_part
      end

      if part_types.include? :attachment
        message.add_file(filename: 'foo.png', content: 'foobar')
      end

      message.ready_to_send!

      message
    end

    def with_body(body_type)
      message = base_message

      case body_type
      when :html
        message.body = HTML_PART_WITH_CSS
        message.content_type 'text/html; charset=UTF-8'
      when :text
        message.body = TEXT_PART
        message.content_type 'text/plain; charset=UTF-8'
      end

      message.ready_to_send!

      message
    end

    def latin_message
      base_message.tap do |message|
        message.body = HTML_PART
        message.content_type 'text/html; charset=UTF-8'
        message.ready_to_send!
      end
    end

    def non_latin_message
      base_message.tap do |message|
        message.body = HTML_PART_WITH_UNICODE
        message.content_type 'text/html; charset=UTF-8'
        message.ready_to_send!
      end
    end

    private

    def base_message
      Mail.new do
        to      'some@email.com'
        subject 'testing premailer-rails'
      end
    end
  end
end
