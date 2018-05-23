require 'active_support/deprecation'
require_relative 'selector_assertions/count_describable'
require_relative 'selector_assertions/html_selector'

module Rails
  module Dom
    module Testing
      module Assertions
        # Adds the +assert_select+ method for use in Rails functional
        # test cases, which can be used to make assertions on the response HTML of a controller
        # action. You can also call +assert_select+ within another +assert_select+ to
        # make assertions on elements selected by the enclosing assertion.
        #
        # Use +css_select+ to select elements without making an assertions, either
        # from the response HTML or elements selected by the enclosing assertion.
        #
        # In addition to HTML responses, you can make the following assertions:
        #
        # * +assert_select_encoded+ - Assertions on HTML encoded inside XML, for example for dealing with feed item descriptions.
        # * +assert_select_email+ - Assertions on the HTML body of an e-mail.
        module SelectorAssertions

        # Select and return all matching elements.
        #
        # If called with a single argument, uses that argument as a selector.
        # Called without an element +css_select+ selects from
        # the element returned in +document_root_element+
        #
        # The default implementation of +document_root_element+ raises an exception explaining this.
        #
        # Returns an empty Nokogiri::XML::NodeSet if no match is found.
        #
        # If called with two arguments, uses the first argument as the root
        # element and the second argument as the selector. Attempts to match the
        # root element and any of its children.
        # Returns an empty Nokogiri::XML::NodeSet if no match is found.
        #
        # The selector may be a CSS selector expression (String).
        # css_select returns nil if called with an invalid css selector.
        #
        #   # Selects all div tags
        #   divs = css_select("div")
        #
        #   # Selects all paragraph tags and does something interesting
        #   pars = css_select("p")
        #   pars.each do |par|
        #     # Do something fun with paragraphs here...
        #   end
        #
        #   # Selects all list items in unordered lists
        #   items = css_select("ul>li")
        #
        #   # Selects all form tags and then all inputs inside the form
        #   forms = css_select("form")
        #   forms.each do |form|
        #     inputs = css_select(form, "input")
        #     ...
        #   end
        def css_select(*args)
          raise ArgumentError, "you at least need a selector argument" if args.empty?

          root = args.size == 1 ? document_root_element : args.shift

          nodeset(root).css(args.first)
        end

        # An assertion that selects elements and makes one or more equality tests.
        #
        # If the first argument is an element, selects all matching elements
        # starting from (and including) that element and all its children in
        # depth-first order.
        #
        # If no element is specified +assert_select+ selects from
        # the element returned in +document_root_element+
        # unless +assert_select+ is called from within an +assert_select+ block.
        # Override +document_root_element+ to tell +assert_select+ what to select from.
        # The default implementation raises an exception explaining this.
        #
        # When called with a block +assert_select+ passes an array of selected elements
        # to the block. Calling +assert_select+ from the block, with no element specified,
        # runs the assertion on the complete set of elements selected by the enclosing assertion.
        # Alternatively the array may be iterated through so that +assert_select+ can be called
        # separately for each element.
        #
        #
        # ==== Example
        # If the response contains two ordered lists, each with four list elements then:
        #   assert_select "ol" do |elements|
        #     elements.each do |element|
        #       assert_select element, "li", 4
        #     end
        #   end
        #
        # will pass, as will:
        #   assert_select "ol" do
        #     assert_select "li", 8
        #   end
        #
        # The selector may be a CSS selector expression (String) or an expression
        # with substitution values (Array).
        # Substitution uses a custom pseudo class match. Pass in whatever attribute you want to match (enclosed in quotes) and a ? for the substitution.
        # assert_select returns nil if called with an invalid css selector.
        #
        # assert_select "div:match('id', ?)", /\d+/
        #
        # === Equality Tests
        #
        # The equality test may be one of the following:
        # * <tt>true</tt> - Assertion is true if at least one element selected.
        # * <tt>false</tt> - Assertion is true if no element selected.
        # * <tt>String/Regexp</tt> - Assertion is true if the text value of at least
        #   one element matches the string or regular expression.
        # * <tt>Integer</tt> - Assertion is true if exactly that number of
        #   elements are selected.
        # * <tt>Range</tt> - Assertion is true if the number of selected
        #   elements fit the range.
        # If no equality test specified, the assertion is true if at least one
        # element selected.
        #
        # To perform more than one equality tests, use a hash with the following keys:
        # * <tt>:text</tt> - Narrow the selection to elements that have this text
        #   value (string or regexp).
        # * <tt>:html</tt> - Narrow the selection to elements that have this HTML
        #   content (string or regexp).
        # * <tt>:count</tt> - Assertion is true if the number of selected elements
        #   is equal to this value.
        # * <tt>:minimum</tt> - Assertion is true if the number of selected
        #   elements is at least this value.
        # * <tt>:maximum</tt> - Assertion is true if the number of selected
        #   elements is at most this value.
        #
        # If the method is called with a block, once all equality tests are
        # evaluated the block is called with an array of all matched elements.
        #
        #   # At least one form element
        #   assert_select "form"
        #
        #   # Form element includes four input fields
        #   assert_select "form input", 4
        #
        #   # Page title is "Welcome"
        #   assert_select "title", "Welcome"
        #
        #   # Page title is "Welcome" and there is only one title element
        #   assert_select "title", {count: 1, text: "Welcome"},
        #       "Wrong title or more than one title element"
        #
        #   # Page contains no forms
        #   assert_select "form", false, "This page must contain no forms"
        #
        #   # Test the content and style
        #   assert_select "body div.header ul.menu"
        #
        #   # Use substitution values
        #   assert_select "ol>li:match('id', ?)", /item-\d+/
        #
        #   # All input fields in the form have a name
        #   assert_select "form input" do
        #     assert_select ":match('name', ?)", /.+/  # Not empty
        #   end
        def assert_select(*args, &block)
          @selected ||= nil

          selector = HTMLSelector.new(args, @selected) { nodeset document_root_element }

          if selector.selecting_no_body?
            assert true
            return
          end

          selector.select.tap do |matches|
            assert_size_match!(matches.size, selector.tests,
              selector.css_selector, selector.message)

            nest_selection(matches, &block) if block_given? && !matches.empty?
          end
        end

        # Extracts the content of an element, treats it as encoded HTML and runs
        # nested assertion on it.
        #
        # You typically call this method within another assertion to operate on
        # all currently selected elements. You can also pass an element or array
        # of elements.
        #
        # The content of each element is un-encoded, and wrapped in the root
        # element +encoded+. It then calls the block with all un-encoded elements.
        #
        #   # Selects all bold tags from within the title of an Atom feed's entries (perhaps to nab a section name prefix)
        #   assert_select "feed[xmlns='http://www.w3.org/2005/Atom']" do
        #     # Select each entry item and then the title item
        #     assert_select "entry>title" do
        #       # Run assertions on the encoded title elements
        #       assert_select_encoded do
        #         assert_select "b"
        #       end
        #     end
        #   end
        #
        #
        #   # Selects all paragraph tags from within the description of an RSS feed
        #   assert_select "rss[version=2.0]" do
        #     # Select description element of each feed item.
        #     assert_select "channel>item>description" do
        #       # Run assertions on the encoded elements.
        #       assert_select_encoded do
        #         assert_select "p"
        #       end
        #     end
        #   end
        def assert_select_encoded(element = nil, &block)
          if !element && !@selected
            raise ArgumentError, "Element is required when called from a nonnested assert_select"
          end

          content = nodeset(element || @selected).map do |elem|
            elem.children.select do |child|
              child.cdata? || (child.text? && !child.blank?)
            end.map(&:content)
          end.join

          selected = Nokogiri::HTML::DocumentFragment.parse(content)
          nest_selection(selected) do
            if content.empty?
              yield selected
            else
              assert_select ":root", &block
            end
          end
        end

        # Extracts the body of an email and runs nested assertions on it.
        #
        # You must enable deliveries for this assertion to work, use:
        #   ActionMailer::Base.perform_deliveries = true
        #
        #  assert_select_email do
        #    assert_select "h1", "Email alert"
        #  end
        #
        #  assert_select_email do
        #    items = assert_select "ol>li"
        #    items.each do
        #       # Work with items here...
        #    end
        #  end
        def assert_select_email(&block)
          deliveries = ActionMailer::Base.deliveries
          assert !deliveries.empty?, "No e-mail in delivery list"

          deliveries.each do |delivery|
            (delivery.parts.empty? ? [delivery] : delivery.parts).each do |part|
              if part["Content-Type"].to_s =~ /^text\/html\W/
                root = Nokogiri::HTML::DocumentFragment.parse(part.body.to_s)
                assert_select root, ":root", &block
              end
            end
          end
        end

        private
          include CountDescribable

          def document_root_element
            raise NotImplementedError, 'Implementing document_root_element makes ' \
              'assert_select work without needing to specify an element to select from.'
          end

          # +equals+ must contain :minimum, :maximum and :count keys
          def assert_size_match!(size, equals, css_selector, message = nil)
            min, max, count = equals[:minimum], equals[:maximum], equals[:count]

            message ||= %(Expected #{count_description(min, max, count)} matching "#{css_selector}", found #{size}.)
            if count
              assert_equal count, size, message
            else
              assert_operator size, :>=, min, message if min
              assert_operator size, :<=, max, message if max
            end
          end

          def nest_selection(selection)
            # Set @selected to allow nested assert_select.
            # Can be nested several levels deep.
            old_selected, @selected = @selected, selection
            yield @selected
          ensure
            @selected = old_selected
          end

          def nodeset(node)
            if node.is_a?(Nokogiri::XML::NodeSet)
              node
            else
              Nokogiri::XML::NodeSet.new(node.document, [node])
            end
          end
        end
      end
    end
  end
end
