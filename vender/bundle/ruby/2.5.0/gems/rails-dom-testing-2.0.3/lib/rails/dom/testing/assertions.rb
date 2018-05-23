require 'active_support/concern'
require 'nokogiri'

module Rails
  module Dom
    module Testing
      module Assertions
        autoload :DomAssertions, 'rails/dom/testing/assertions/dom_assertions'
        autoload :SelectorAssertions, 'rails/dom/testing/assertions/selector_assertions'

        extend ActiveSupport::Concern

        include DomAssertions
        include SelectorAssertions
      end
    end
  end
end