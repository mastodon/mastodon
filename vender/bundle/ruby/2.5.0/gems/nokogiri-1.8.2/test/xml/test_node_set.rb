require "helper"

module Nokogiri
  module XML
    class TestNodeSet < Nokogiri::TestCase
      class TestNodeSetNamespaces < Nokogiri::TestCase
        def setup
          super
          @xml = Nokogiri.XML('<foo xmlns:n0="http://example.com" />')
          @list = @xml.xpath('//namespace::*')
        end

        def test_include?
          assert @list.include?(@list.first), 'list should have item'
        end

        def test_push
          @list.push @list.first
        end

        def test_delete
          @list.push @list.first
          @list.delete @list.first
        end
        
        def test_reference_after_delete
          first = @list.first
          @list.delete(first)
          assert_equal 'http://www.w3.org/XML/1998/namespace', first.href
        end        
      end

      def setup
        super
        @xml = Nokogiri::XML(File.read(XML_FILE), XML_FILE)
        @list = @xml.css('employee')
      end

      def test_break_works
        assert_equal 7, @xml.root.elements.each { |x| break 7 }
      end

      def test_filter
        list = @xml.css('address').filter('*[domestic="Yes"]')
        assert_equal(%w{ Yes } * 4, list.map { |n| n['domestic'] })
      end

      def test_remove_attr
        @list.each { |x| x['class'] = 'blah' }
        assert_equal @list, @list.remove_attr('class')
        @list.each { |x| assert_nil x['class'] }
      end

      def test_add_class
        assert_equal @list, @list.add_class('bar')
        @list.each { |x| assert_equal 'bar', x['class'] }

        @list.add_class('bar')
        @list.each { |x| assert_equal 'bar', x['class'] }

        @list.add_class('baz')
        @list.each { |x| assert_equal 'bar baz', x['class'] }
      end

      def test_remove_class_with_no_class
        assert_equal @list, @list.remove_class('bar')
        @list.each { |e| assert_nil e['class'] }

        @list.each { |e| e['class'] = '' }
        assert_equal @list, @list.remove_class('bar')
        @list.each { |e| assert_nil e['class'] }
      end

      def test_remove_class_single
        @list.each { |e| e['class'] = 'foo bar' }

        assert_equal @list, @list.remove_class('bar')
        @list.each { |e| assert_equal 'foo', e['class'] }
      end

      def test_remove_class_completely
        @list.each { |e| e['class'] = 'foo' }

        assert_equal @list, @list.remove_class
        @list.each { |e| assert_nil e['class'] }
      end

      def test_attribute_set
        @list.each { |e| assert_nil e['foo'] }

        [ ['attribute', 'bar'], ['attr', 'biz'], ['set', 'baz'] ].each do |t|
          @list.send(t.first.to_sym, 'foo', t.last)
          @list.each { |e| assert_equal t.last, e['foo'] }
        end
      end

      def test_attribute_set_with_block
        @list.each { |e| assert_nil e['foo'] }

        [ ['attribute', 'bar'], ['attr', 'biz'], ['set', 'baz'] ].each do |t|
          @list.send(t.first.to_sym, 'foo') { |x| t.last }
          @list.each { |e| assert_equal t.last, e['foo'] }
        end
      end

      def test_attribute_set_with_hash
        @list.each { |e| assert_nil e['foo'] }

        [ ['attribute', 'bar'], ['attr', 'biz'], ['set', 'baz'] ].each do |t|
          @list.send(t.first.to_sym, 'foo' => t.last)
          @list.each { |e| assert_equal t.last, e['foo'] }
        end
      end

      def test_attribute_no_args
        @list.first['foo'] = 'bar'
        assert_equal @list.first.attribute('foo'), @list.attribute('foo')
      end

      def test_search_empty_node_set
        set = Nokogiri::XML::NodeSet.new(Nokogiri::XML::Document.new)
        assert_equal 0, set.css('foo').length
        assert_equal 0, set.xpath('.//foo').length
        assert_equal 0, set.search('foo').length
      end

      def test_node_set_search_with_multiple_queries
        xml = '<document>
                 <thing>
                   <div class="title">important thing</div>
                 </thing>
                 <thing>
                   <div class="content">stuff</div>
                 </thing>
                 <thing>
                   <p class="blah">more stuff</div>
                 </thing>
               </document>'
        set = Nokogiri::XML(xml).xpath(".//thing")
        assert_kind_of Nokogiri::XML::NodeSet, set

        assert_equal 3, set.xpath('./div', './p').length
        assert_equal 3, set.css('.title', '.content', 'p').length
        assert_equal 3, set.search('./div', 'p.blah').length
      end

      def test_search_with_custom_selector
        set = @xml.xpath('//staff')

        [
          [:xpath,  '//*[awesome(.)]'],
          [:search, '//*[awesome(.)]'],
          [:css,    '*:awesome'],
          [:search, '*:awesome']
        ].each do |method, query|
          custom_employees = set.send(method, query, Class.new {
              def awesome ns
                ns.select { |n| n.name == 'employee' }
              end
            }.new)

          assert_equal(@xml.xpath('//employee'), custom_employees,
            "using #{method} with custom selector '#{query}'")
        end
      end

      def test_search_with_variable_bindings
        set = @xml.xpath('//staff')

        assert_equal(4, set.xpath('//address[@domestic=$value]', nil, :value => 'Yes').length,
          "using #xpath with variable binding")

        assert_equal(4, set.search('//address[@domestic=$value]', nil, :value => 'Yes').length,
          "using #search with variable binding")
      end

      def test_search_self
        set = @xml.xpath('//staff')
        assert_equal set.to_a, set.search('.').to_a
      end

      def test_css_searches_match_self
        html = Nokogiri::HTML("<html><body><div class='a'></div></body></html>")
        set = html.xpath("/html/body/div")
        assert_equal set.first, set.css(".a").first
        assert_equal set.first, set.search(".a").first
      end

      def test_css_search_with_namespace
        fragment = Nokogiri::XML.fragment(<<-eoxml)
          <html xmlns="http://www.w3.org/1999/xhtml">
          <head></head>
          <body></body>
          </html>
        eoxml
        assert fragment.children.search( 'body', { 'xmlns' => 'http://www.w3.org/1999/xhtml' })
      end

      def test_double_equal
        assert node_set_one = @xml.xpath('//employee')
        assert node_set_two = @xml.xpath('//employee')

        assert_not_equal node_set_one.object_id, node_set_two.object_id

        assert_equal node_set_one, node_set_two
      end

      def test_node_set_not_equal_to_string
        node_set_one = @xml.xpath('//employee')
        assert_not_equal node_set_one, "asdfadsf"
      end

      def test_out_of_order_not_equal
        one = @xml.xpath('//employee')
        two = @xml.xpath('//employee')
        two.push two.shift
        assert_not_equal one, two
      end

      def test_shorter_is_not_equal
        node_set_one = @xml.xpath('//employee')
        node_set_two = @xml.xpath('//employee')
        node_set_two.delete(node_set_two.first)

        assert_not_equal node_set_one, node_set_two
      end

      def test_pop
        set = @xml.xpath('//employee')
        last = set.last
        assert_equal last, set.pop
      end

      def test_shift
        set = @xml.xpath('//employee')
        first = set.first
        assert_equal first, set.shift
      end

      def test_shift_empty
        set = Nokogiri::XML::NodeSet.new(@xml)
        assert_nil set.shift
      end

      def test_pop_empty
        set = Nokogiri::XML::NodeSet.new(@xml)
        assert_nil set.pop
      end

      def test_first_takes_arguments
        assert node_set = @xml.xpath('//employee')
        assert_equal 2, node_set.first(2).length
      end
      
      def test_first_clamps_arguments
        assert node_set = @xml.xpath('//employee[position() < 3]')
        assert_equal 2, node_set.first(5).length
      end

      [:dup, :clone].each do |method_name|
        define_method "test_#{method_name}" do
          assert node_set = @xml.xpath('//employee')
          duplicate = node_set.send(method_name)
          assert_equal node_set.length, duplicate.length
          node_set.zip(duplicate).each do |a,b|
            assert_equal a, b
          end
        end
      end

      def test_dup_on_empty_set
        empty_set = Nokogiri::XML::NodeSet.new @xml, []
        assert_equal 0, empty_set.dup.length # this shouldn't raise null pointer exception
      end

      def test_xmlns_is_automatically_registered
        doc = Nokogiri::XML(<<-eoxml)
          <root xmlns="http://tenderlovemaking.com/">
            <foo>
              <bar/>
            </foo>
          </root>
        eoxml
        set = doc.css('foo')
        assert_equal 1, set.css('xmlns|bar').length
        assert_equal 0, set.css('|bar').length
        assert_equal 1, set.xpath('//xmlns:bar').length
        assert_equal 1, set.search('xmlns|bar').length
        assert_equal 1, set.search('//xmlns:bar').length
        assert set.at('//xmlns:bar')
        assert set.at('xmlns|bar')
        assert set.at('bar')
      end

      def test_children_has_document
        set = @xml.root.children
        assert_instance_of(NodeSet, set)
        assert_equal @xml, set.document
      end

      def test_length_size
        assert node_set = @xml.search('//employee')
        assert_equal node_set.length, node_set.size
      end

      def test_to_xml
        assert node_set = @xml.search('//employee')
        assert node_set.to_xml
      end

      def test_inner_html
        doc = Nokogiri::HTML(<<-eohtml)
          <html>
            <body>
              <div>
                <a>one</a>
              </div>
              <div>
                <a>two</a>
              </div>
            </body>
          </html>
        eohtml
        assert html = doc.css('div').inner_html
        assert_match '<a>', html
      end

      def test_gt_string_arg
        assert node_set = @xml.search('//employee')
        assert_equal node_set.xpath('./employeeId'), (node_set > 'employeeId')
      end

      def test_at_performs_a_search_with_css
        assert node_set = @xml.search('//employee')
        assert_equal node_set.first.first_element_child, node_set.at('employeeId')
        assert_equal node_set.first.first_element_child, node_set.%('employeeId')
      end

      def test_at_performs_a_search_with_xpath
        assert node_set = @xml.search('//employee')
        assert_equal node_set.first.first_element_child, node_set.at('./employeeId')
        assert_equal node_set.first.first_element_child, node_set.%('./employeeId')
      end

      def test_at_with_integer_index
        assert node_set = @xml.search('//employee')
        assert_equal node_set.first, node_set.at(0)
        assert_equal node_set.first, node_set % 0
      end

      def test_at_xpath
        assert node_set = @xml.search('//employee')
        assert_equal node_set.first.first_element_child, node_set.at_xpath('./employeeId')
      end

      def test_at_css
        assert node_set = @xml.search('//employee')
        assert_equal node_set.first.first_element_child, node_set.at_css('employeeId')
      end

      def test_to_ary
        assert node_set = @xml.search('//employee')
        foo = []
        foo += node_set
        assert_equal node_set.length, foo.length
      end

      def test_push
        node = Nokogiri::XML::Node.new('foo', @xml)
        node.content = 'bar'

        assert node_set = @xml.search('//employee')
        node_set.push(node)

        assert node_set.include?(node)
      end

      def test_delete_with_invalid_argument
        employees = @xml.search("//employee")
        positions = @xml.search("//position")

        assert_raises(ArgumentError) { employees.delete(positions) }
      end

      def test_delete_when_present
        employees = @xml.search("//employee")
        wally = employees.first
        assert employees.include?(wally) # testing setup
        length = employees.length

        result = employees.delete(wally)
        assert_equal result, wally
        assert ! employees.include?(wally)
        assert length-1, employees.length
      end

      def test_delete_when_not_present
        employees = @xml.search("//employee")
        phb = @xml.search("//position").first
        assert ! employees.include?(phb) # testing setup
        length = employees.length

        result = employees.delete(phb)
        assert_nil result
        assert length, employees.length
      end

      def test_delete_on_empty_set
        empty_set = Nokogiri::XML::NodeSet.new @xml, []
        employee  = @xml.at_xpath("//employee")
        assert_equal nil, empty_set.delete(employee)
      end

      def test_unlink
        xml = Nokogiri::XML.parse(<<-eoxml)
        <root>
          <a class='foo bar'>Bar</a>
          <a class='bar foo'>Bar</a>
          <a class='bar'>Bar</a>
          <a>Hello world</a>
          <a class='baz bar foo'>Bar</a>
          <a class='bazbarfoo'>Awesome</a>
          <a class='bazbar'>Awesome</a>
        </root>
        eoxml
        set = xml.xpath('//a')
        set.unlink
        set.each do |node|
          assert !node.parent
          #assert !node.document
          assert !node.previous_sibling
          assert !node.next_sibling
        end
        assert_no_match(/Hello world/, xml.to_s)
      end

      def test_nodeset_search_takes_namespace
        @xml = Nokogiri::XML.parse(<<-eoxml)
<root>
 <car xmlns:part="http://general-motors.com/">
  <part:tire>Michelin Model XGV</part:tire>
 </car>
 <bicycle xmlns:part="http://schwinn.com/">
  <part:tire>I'm a bicycle tire!</part:tire>
 </bicycle>
</root>
        eoxml
        set = @xml/'root'
        assert_equal 1, set.length
        bike_tire = set.search('//bike:tire', 'bike' => "http://schwinn.com/")
        assert_equal 1, bike_tire.length
      end

      def test_new_nodeset
        node_set = Nokogiri::XML::NodeSet.new(@xml)
        assert_equal(0, node_set.length)
        node = Nokogiri::XML::Node.new('form', @xml)
        node_set << node
        assert_equal(1, node_set.length)
        assert_equal(node, node_set.last)
      end

      def test_search_on_nodeset
        assert node_set = @xml.search('//employee')
        assert sub_set = node_set.search('.//name')
        assert_equal(node_set.length, sub_set.length)
      end

      def test_negative_index_works
        assert node_set = @xml.search('//employee')
        assert_equal node_set.last, node_set[-1]
      end

      def test_large_negative_index_returns_nil
        assert node_set = @xml.search('//employee')
        assert_nil(node_set[-1 * (node_set.length + 1)])
      end

      def test_node_set_fetches_private_data
        assert node_set = @xml.search('//employee')

        set = node_set
        assert_equal(set[0], set[0])
      end

      def test_node_set_returns_0
        assert node_set = @xml.search('//asdkfjhasdlkfjhaldskfh')
        assert_equal(0, node_set.length)
      end

      def test_wrap
        employees = (@xml/"//employee").wrap("<wrapper/>")
        assert_equal 'wrapper', employees[0].parent.name
        assert_equal 'employee', @xml.search("//wrapper").first.children[0].name
      end

      def test_wrap_a_fragment
        frag = Nokogiri::XML::DocumentFragment.parse <<-EOXML
          <employees>
            <employee>hello</employee>
            <employee>goodbye</employee>
          </employees>
        EOXML
        employees = frag.xpath ".//employee"
        employees.wrap("<wrapper/>")
        assert_equal 'wrapper', employees[0].parent.name
        assert_equal 'employee', frag.at(".//wrapper").children.first.name
      end

      def test_wrap_preserves_document_structure
        assert_equal "employeeId",
                     @xml.at_xpath("//employee").children.detect{|j| ! j.text? }.name
        @xml.xpath("//employeeId[text()='EMP0001']").wrap("<wrapper/>")
        assert_equal "wrapper",
                     @xml.at_xpath("//employee").children.detect{|j| ! j.text? }.name
      end

      def test_plus_operator
        names = @xml.search("name")
        positions = @xml.search("position")

        names_len = names.length
        positions_len = positions.length

        assert_raises(ArgumentError) { names + positions.first }

        result = names + positions
        assert_equal names_len,                         names.length
        assert_equal positions_len,                     positions.length
        assert_equal names.length + positions.length,   result.length

        names += positions
        assert_equal result.length, names.length
      end

      def test_union
        names = @xml.search("name")

        assert_equal(names.length, (names | @xml.search("name")).length)
      end

      def test_minus_operator
        employees = @xml.search("//employee")
        females = @xml.search("//employee[gender[text()='Female']]")

        employees_len = employees.length
        females_len = females.length

        assert_raises(ArgumentError) { employees - females.first }

        result = employees - females
        assert_equal employees_len,                     employees.length
        assert_equal females_len,                       females.length
        assert_equal employees.length - females.length, result.length

        employees -= females
        assert_equal result.length, employees.length
      end

      def test_array_index
        employees = @xml.search("//employee")
        other = @xml.search("//position").first

        assert_equal 3, employees.index(employees[3])
        assert_nil employees.index(other)
      end

      def test_slice_too_far
        employees = @xml.search("//employee")
        assert_equal employees.length, employees[0, employees.length + 1].length
        assert_equal employees.length, employees[0, employees.length].length
      end

      def test_slice_on_empty_node_set
        empty_set = Nokogiri::XML::NodeSet.new @xml, []
        assert_equal nil, empty_set[99]
        assert_equal nil, empty_set[99..101]
        assert_equal nil, empty_set[99,2]
      end

      def test_slice_waaaaaay_off_the_end
        xml = Nokogiri::XML::Builder.new {
          root { 100.times { div } }
        }.doc
        nodes = xml.css "div"
        assert_equal 1, nodes.slice(99,  100_000).length
        assert_equal 0, nodes.slice(100, 100_000).length
      end

      def test_array_slice_with_start_and_end
        employees = @xml.search("//employee")
        assert_equal [employees[1], employees[2], employees[3]], employees[1,3].to_a
      end

      def test_array_index_bracket_equivalence
        employees = @xml.search("//employee")
        assert_equal [employees[1], employees[2], employees[3]], employees[1,3].to_a
        assert_equal [employees[1], employees[2], employees[3]], employees.slice(1,3).to_a
      end

      def test_array_slice_with_negative_start
        employees = @xml.search("//employee")
        assert_equal [employees[2]],                    employees[-3,1].to_a
        assert_equal [employees[2], employees[3]],      employees[-3,2].to_a
      end

      def test_array_slice_with_invalid_args
        employees = @xml.search("//employee")
        assert_nil employees[99, 1] # large start
        assert_nil employees[1, -1] # negative len
        assert_equal [], employees[1, 0].to_a # zero len
      end

      def test_array_slice_with_range
        employees = @xml.search("//employee")
        assert_equal [employees[1], employees[2], employees[3]], employees[1..3].to_a
        assert_equal [employees[0], employees[1], employees[2], employees[3]], employees[0..3].to_a
      end

      def test_intersection_with_no_overlap
        employees = @xml.search("//employee")
        positions = @xml.search("//position")

        assert_equal [], (employees & positions).to_a
      end

      def test_intersection
        employees = @xml.search("//employee")
        first_set = employees[0..2]
        second_set = employees[2..4]

        assert_equal [employees[2]], (first_set & second_set).to_a
      end

      def test_intersection_on_empty_set
        empty_set = Nokogiri::XML::NodeSet.new @xml
        employees = @xml.search("//employee")
        assert_equal 0, (empty_set & employees).length
      end

      def test_include?
        employees = @xml.search("//employee")
        yes = employees.first
        no = @xml.search("//position").first

        assert employees.include?(yes)
        assert ! employees.include?(no)
      end

      def test_include_on_empty_node_set
        empty_set = Nokogiri::XML::NodeSet.new @xml, []
        employee  = @xml.at_xpath("//employee")
        assert ! empty_set.include?(employee)
      end

      def test_children
        employees = @xml.search("//employee")
        count = 0
        employees.each do |employee|
          count += employee.children.length
        end
        set = employees.children
        assert_equal count, set.length
      end

      def test_inspect
        employees = @xml.search("//employee")
        inspected = employees.inspect

        assert_equal "[#{employees.map(&:inspect).join(', ')}]",
          inspected
      end

      def test_should_not_splode_when_accessing_namespace_declarations_in_a_node_set
        2.times do
          xml = Nokogiri::XML "<foo></foo>"
          node_set = xml.xpath("//namespace::*")
          assert_equal 1, node_set.size
          node = node_set.first
          node.to_s # segfaults in 1.4.0 and earlier

          # if we haven't segfaulted, let's make sure we handled it correctly
          assert_instance_of Nokogiri::XML::Namespace, node
        end
      end

      def test_should_not_splode_when_arrayifying_node_set_containing_namespace_declarations
        xml = Nokogiri::XML "<foo></foo>"
        node_set = xml.xpath("//namespace::*")
        assert_equal 1, node_set.size

        node_array = node_set.to_a
        node = node_array.first
        node.to_s # segfaults in 1.4.0 and earlier

        # if we haven't segfaulted, let's make sure we handled it correctly
        assert_instance_of Nokogiri::XML::Namespace, node
      end

      def test_should_not_splode_when_unlinking_node_set_containing_namespace_declarations
        xml = Nokogiri::XML "<foo></foo>"
        node_set = xml.xpath("//namespace::*")
        assert_equal 1, node_set.size

        node_set.unlink
      end

      def test_reverse
        xml = Nokogiri::XML "<root><a />b<c />d<e /></root>"
        children = xml.root.children
        assert_instance_of Nokogiri::XML::NodeSet, children

        reversed = children.reverse
        assert_equal reversed[0], children[4]
        assert_equal reversed[1], children[3]
        assert_equal reversed[2], children[2]
        assert_equal reversed[3], children[1]
        assert_equal reversed[4], children[0]

        assert_equal children, children.reverse.reverse
      end

      def test_node_set_dup_result_has_document_and_is_decorated
        x = Module.new do
          def awesome! ; end
        end
        util_decorate(@xml, x)
        node_set = @xml.css("address")
        new_set  = node_set.dup
        assert_equal node_set.document, new_set.document
        assert new_set.respond_to?(:awesome!)
      end

      def test_node_set_union_result_has_document_and_is_decorated
        x = Module.new do
          def awesome! ; end
        end
        util_decorate(@xml, x)
        node_set1 = @xml.css("address")
        node_set2 = @xml.css("address")
        new_set  = node_set1 | node_set2
        assert_equal node_set1.document, new_set.document
        assert new_set.respond_to?(:awesome!)
      end

      def test_node_set_intersection_result_has_document_and_is_decorated
        x = Module.new do
          def awesome! ; end
        end
        util_decorate(@xml, x)
        node_set1 = @xml.css("address")
        node_set2 = @xml.css("address")
        new_set  = node_set1 & node_set2
        assert_equal node_set1.document, new_set.document
        assert new_set.respond_to?(:awesome!)
      end

      def test_node_set_difference_result_has_document_and_is_decorated
        x = Module.new do
          def awesome! ; end
        end
        util_decorate(@xml, x)
        node_set1 = @xml.css("address")
        node_set2 = @xml.css("address")
        new_set  = node_set1 - node_set2
        assert_equal node_set1.document, new_set.document
        assert new_set.respond_to?(:awesome!)
      end

      def test_node_set_slice_result_has_document_and_is_decorated
        x = Module.new do
          def awesome! ; end
        end
        util_decorate(@xml, x)
        node_set = @xml.css("address")
        new_set  = node_set[0..-1]
        assert_equal node_set.document, new_set.document
        assert new_set.respond_to?(:awesome!)
      end
    end
  end
end
