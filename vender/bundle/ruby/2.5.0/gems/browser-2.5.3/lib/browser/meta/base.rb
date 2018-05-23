# frozen_string_literal: true

module Browser
  module Meta
    def self.rules
      @rules ||= [
        Device,
        GenericBrowser,
        Id,
        IE,
        IOS,
        Mobile,
        Modern,
        Platform,
        Proxy,
        Safari,
        Tablet,
        Webkit
      ]
    end

    def self.get(browser)
      rules.each_with_object(Set.new) do |rule, meta|
        meta.merge(rule.new(browser).to_a)
      end.to_a
    end

    class Base
      # Set the browser instance.
      attr_reader :browser

      def initialize(browser)
        @browser = browser
      end

      def meta
        nil
      end

      def to_a
        meta.to_s.squeeze(" ").split(" ")
      end
    end
  end
end
