# frozen_string_literal: true
require 'hamlit/hamlit'

module Hamlit
  module Utils
    def self.escape_html_safe(html)
      html.html_safe? ? html : escape_html(html)
    end
  end
end
