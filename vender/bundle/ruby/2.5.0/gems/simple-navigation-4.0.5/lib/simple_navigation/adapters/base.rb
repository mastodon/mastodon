module SimpleNavigation
  module Adapters
    # This is the base class for all adapters.
    # This class mainly exists for documenting reasons.
    # It lists all the methods that an adapter should implement.
    #
    class Base
      attr_reader :context, :request

      # This method is usually called when the framework is initialized.
      # It should call SimpleNavigation.set_env and install
      # SimpleNavigation::Helpers where appropriate.
      def self.register; end

      # Returns the full path incl. query params
      def request_uri; end

      # Returns the path without query params
      def request_path; end

      # Returns the context in which the config files will be evaluated
      def context_for_eval; end

      # Returns true if the current request's url matches the specified url.
      # Used to determine if an item should be autohighlighted.
      def current_page?(url); end

      # Returns a link with the specified name, url and options.
      # Used for rendering.
      def link_to(name, url, options = {}); end

      # Returns a tag of the specified type, content and options.
      # Used for rendering.
      def content_tag(type, content, options = {}); end
    end
  end
end
