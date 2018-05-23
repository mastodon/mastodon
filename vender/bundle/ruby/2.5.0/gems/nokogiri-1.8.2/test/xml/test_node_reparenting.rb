require "helper"

module Nokogiri
  module XML
    class TestNodeReparenting < Nokogiri::TestCase

      describe "standard node reparenting behavior" do
        # describe "namespace handling during reparenting" do
        #   describe "given a Node" do
        #     describe "with a Namespace" do
        #       it "keeps the Namespace"
        #     end
        #     describe "given a parent Node with a default and a non-default Namespace" do
        #       describe "passed an Node without a namespace" do
        #         it "inserts an Node that inherits the default Namespace"
        #       end
        #       describe "passed a Node with a Namespace that matches the parent's non-default Namespace" do
        #         it "inserts a Node that inherits the matching parent Namespace"
        #       end
        #     end
        #   end
        #   describe "given a markup string" do
        #     describe "parsed relative to the document" do
        #       describe "with a Namespace" do
        #         it "keeps the Namespace"
        #       end
        #       describe "given a parent Node with a default and a non-default Namespace" do
        #         describe "passed an Node without a namespace" do
        #           it "inserts an Node that inherits the default Namespace"
        #         end
        #         describe "passed a Node with a Namespace that matches the parent's non-default Namespace" do
        #           it "inserts a Node that inherits the matching parent Namespace"
        #         end
        #       end
        #     end
        #     describe "parsed relative to a specific node" do
        #       describe "with a Namespace" do
        #         it "keeps the Namespace"
        #       end
        #       describe "given a parent Node with a default and a non-default Namespace" do
        #         describe "passed an Node without a namespace" do
        #           it "inserts an Node that inherits the default Namespace"
        #         end
        #         describe "passed a Node with a Namespace that matches the parent's non-default Namespace" do
        #           it "inserts a Node that inherits the matching parent Namespace"
        #         end
        #       end
        #     end
        #   end
        # end


        before do
          @doc  = Nokogiri::XML "<root><a1>First node</a1><a2>Second node</a2><a3>Third <bx />node</a3></root>"
          @doc2 = @doc.dup
          @fragment_string = "<b1>foo</b1><b2>bar</b2>"
          @fragment        = Nokogiri::XML::DocumentFragment.parse @fragment_string
          @node_set        = Nokogiri::XML("<root><b1>foo</b1><b2>bar</b2></root>").xpath("/root/node()")
        end

        {
          :add_child            => {:target => "/root/a1",        :returns_self => false, :children_tags => %w[text b1 b2]},
          :<<                   => {:target => "/root/a1",        :returns_self => true, :children_tags => %w[text b1 b2]},

          :replace              => {:target => "/root/a1/node()", :returns_self => false, :children_tags => %w[b1 b2]},
          :swap                 => {:target => "/root/a1/node()", :returns_self => true,  :children_tags => %w[b1 b2]},

          :children=            => {:target => "/root/a1",        :returns_self => false, :children_tags => %w[b1 b2]},
          :inner_html=          => {:target => "/root/a1",        :returns_self => true,  :children_tags => %w[b1 b2]},

          :add_previous_sibling => {:target => "/root/a1/text()", :returns_self => false, :children_tags => %w[b1 b2 text]},
          :previous=            => {:target => "/root/a1/text()", :returns_self => false, :children_tags => %w[b1 b2 text]},
          :before               => {:target => "/root/a1/text()", :returns_self => true,  :children_tags => %w[b1 b2 text]},

          :add_next_sibling     => {:target => "/root/a1/text()", :returns_self => false, :children_tags => %w[text b1 b2]},
          :next=                => {:target => "/root/a1/text()", :returns_self => false, :children_tags => %w[text b1 b2]},
          :after                => {:target => "/root/a1/text()", :returns_self => true,  :children_tags => %w[text b1 b2]}
        }.each do |method, params|
          describe "##{method}" do
            describe "passed a Node" do
              [:current, :another].each do |which|
                describe "passed a Node in the #{which} document" do
                  before do
                    @other_doc = which == :current ? @doc : @doc2
                    @other_node = @other_doc.at_xpath("/root/a2")
                  end

                  it "unlinks the Node from its previous position" do
                    @doc.at_xpath(params[:target]).send(method, @other_node)
                    @other_doc.at_xpath("/root/a2").must_be_nil
                  end

                  it "inserts the Node in the proper position" do
                    @doc.at_xpath(params[:target]).send(method, @other_node)
                    @doc.at_xpath("/root/a1/a2").wont_be_nil
                  end

                  it "returns the expected value" do
                    sendee = @doc.at_xpath(params[:target])
                    result = sendee.send(method, @other_node)
                    if params[:returns_self]
                      result.must_equal sendee
                    else
                      result.must_equal @other_node
                    end
                  end
                end
              end
            end
            describe "passed a markup string" do
              it "inserts the fragment roots in the proper position" do
                @doc.at_xpath(params[:target]).send(method, @fragment_string)
                @doc.xpath("/root/a1/node()").collect {|n| n.name}.must_equal params[:children_tags]
              end

              it "returns the expected value" do
                sendee = @doc.at_xpath(params[:target])
                result = sendee.send(method, @fragment_string)
                if params[:returns_self]
                  result.must_equal sendee
                else
                  result.must_be_kind_of Nokogiri::XML::NodeSet
                  result.to_html.must_equal @fragment_string
                end
              end
            end
            describe "passed a fragment" do
              it "inserts the fragment roots in the proper position" do
                @doc.at_xpath(params[:target]).send(method, @fragment)
                @doc.xpath("/root/a1/node()").collect {|n| n.name}.must_equal params[:children_tags]
              end
            end
            describe "passed a document" do
              it "raises an exception" do
                proc { @doc.at_xpath("/root/a1").send(method, @doc2) }.must_raise(ArgumentError)
              end
            end
            describe "passed a non-Node" do
              it "raises an exception" do
                proc { @doc.at_xpath("/root/a1").send(method, 42) }.must_raise(ArgumentError)
              end
            end
            describe "passed a NodeSet" do
              it "inserts each member of the NodeSet in the proper order" do
                @doc.at_xpath(params[:target]).send(method, @node_set)
                @doc.xpath("/root/a1/node()").collect {|n| n.name}.must_equal params[:children_tags]
              end
            end
          end
        end

        describe "text node merging" do
          describe "#add_child" do
            it "merges the Text node with adjacent Text nodes" do
              @doc.at_xpath("/root/a1").add_child Nokogiri::XML::Text.new('hello', @doc)
              @doc.at_xpath("/root/a1/text()").content.must_equal "First nodehello"
            end
          end

          describe "#replace" do
            it "merges the Text node with adjacent Text nodes" do
              @doc.at_xpath("/root/a3/bx").replace Nokogiri::XML::Text.new('hello', @doc)
              @doc.at_xpath("/root/a3/text()").content.must_equal "Third hellonode"
            end
          end
        end
      end

      describe "ad hoc node reparenting behavior" do
        describe "#<<" do
          it "allows chaining" do
            doc   = Nokogiri::XML::Document.new
            root  = Nokogiri::XML::Element.new('root', doc)
            doc.root = root

            child1 = Nokogiri::XML::Element.new('child1', doc)
            child2 = Nokogiri::XML::Element.new('child2', doc)

            doc.root << child1 << child2

            assert_equal [child1, child2], doc.root.children.to_a
          end
        end

        describe "#add_child" do
          describe "given a new node with a namespace" do
            it "keeps the namespace" do
              doc   = Nokogiri::XML::Document.new
              item  = Nokogiri::XML::Element.new('item', doc)
              doc.root = item

              entry = Nokogiri::XML::Element.new('entry', doc)
              entry.add_namespace('tlm', 'http://tenderlovemaking.com')
              assert_equal 'http://tenderlovemaking.com', entry.namespaces['xmlns:tlm']
              item.add_child(entry)
              assert_equal 'http://tenderlovemaking.com', entry.namespaces['xmlns:tlm']
            end
          end

          describe "given a parent node with a default namespace" do
            before do
              @doc = Nokogiri::XML(<<-eoxml)
                <root xmlns="http://tenderlovemaking.com/">
                  <first>
                  </first>
                </root>
              eoxml
            end

            it "inserts a node that inherits the default namespace" do
              assert node = @doc.at('//xmlns:first')
              child = Nokogiri::XML::Node.new('second', @doc)
              node.add_child(child)
              assert @doc.at('//xmlns:second')
            end
          end

          describe "given a parent node with a default and non-default namespace" do
            before do
              @doc = Nokogiri::XML(<<-eoxml)
                <root xmlns="http://tenderlovemaking.com/" xmlns:foo="http://flavorjon.es/">
                  <first>
                  </first>
                </root>
              eoxml
              assert @node = @doc.at('//xmlns:first')
              @child = Nokogiri::XML::Node.new('second', @doc)
            end

            describe "and a child with a namespace matching the parent's default namespace" do
              describe "and as the default prefix" do
                before do
                  @ns = @child.add_namespace(nil, 'http://tenderlovemaking.com/')
                  @child.namespace = @ns
                end

                it "inserts a node that inherits the parent's default namespace" do
                  @node.add_child(@child)
                  assert reparented = @doc.at('//bar:second', "bar" => "http://tenderlovemaking.com/")
                  assert reparented.namespace_definitions.empty?
                  assert_equal @ns, reparented.namespace
                  assert_equal(
                    {
                      "xmlns"     => "http://tenderlovemaking.com/",
                      "xmlns:foo" => "http://flavorjon.es/",
                    },
                    reparented.namespaces)
                end
              end

              describe "but with a different prefix" do
                before do
                  @ns = @child.add_namespace("baz", 'http://tenderlovemaking.com/')
                  @child.namespace = @ns
                end

                it "inserts a node that uses its own namespace" do
                  @node.add_child(@child)
                  assert reparented = @doc.at('//bar:second', "bar" => "http://tenderlovemaking.com/")
                  assert reparented.namespace_definitions.include?(@ns)
                  assert_equal @ns, reparented.namespace
                  assert_equal(
                    {
                      "xmlns"     => "http://tenderlovemaking.com/",
                      "xmlns:foo" => "http://flavorjon.es/",
                      "xmlns:baz" => "http://tenderlovemaking.com/",
                    },
                    reparented.namespaces)
                end
              end
            end

            describe "and a child with a namespace matching the parent's non-default namespace" do
              describe "set by #namespace=" do
                before do
                  @ns = @doc.root.namespace_definitions.detect { |x| x.prefix == "foo" }
                  @child.namespace = @ns
                end

                it "inserts a node that inherits the matching parent namespace" do
                  @node.add_child(@child)
                  assert reparented = @doc.at('//bar:second', "bar" => "http://flavorjon.es/")
                  assert reparented.namespace_definitions.empty?
                  assert_equal @ns, reparented.namespace
                  assert_equal(
                    {
                      "xmlns"     => "http://tenderlovemaking.com/",
                      "xmlns:foo" => "http://flavorjon.es/",
                    },
                    reparented.namespaces)
                end
              end

              describe "with the same prefix" do
                before do
                  @ns = @child.add_namespace("foo", 'http://flavorjon.es/')
                  @child.namespace = @ns
                end

                it "inserts a node that uses the parent's namespace" do
                  @node.add_child(@child)
                  assert reparented = @doc.at('//bar:second', "bar" => "http://flavorjon.es/")
                  assert reparented.namespace_definitions.empty?
                  assert_equal @ns, reparented.namespace
                  assert_equal(
                    {
                      "xmlns"     => "http://tenderlovemaking.com/",
                      "xmlns:foo" => "http://flavorjon.es/",
                    },
                    reparented.namespaces)
                end
              end

              describe "as the default prefix" do
                before do
                  @ns = @child.add_namespace(nil, 'http://flavorjon.es/')
                  @child.namespace = @ns
                end

                it "inserts a node that keeps its namespace" do
                  @node.add_child(@child)
                  assert reparented = @doc.at('//bar:second', "bar" => "http://flavorjon.es/")
                  assert reparented.namespace_definitions.include?(@ns)
                  assert_equal @ns, reparented.namespace
                  assert_equal(
                    {
                      "xmlns"     => "http://flavorjon.es/",
                      "xmlns:foo" => "http://flavorjon.es/",
                    },
                    reparented.namespaces)
                end
              end

              describe "but with a different prefix" do
                before do
                  @ns = @child.add_namespace('baz', 'http://flavorjon.es/')
                  @child.namespace = @ns
                end

                it "inserts a node that keeps its namespace" do
                  @node.add_child(@child)
                  assert reparented = @doc.at('//bar:second', "bar" => "http://flavorjon.es/")
                  assert reparented.namespace_definitions.include?(@ns)
                  assert_equal @ns, reparented.namespace
                  assert_equal(
                    {
                      "xmlns"     =>"http://tenderlovemaking.com/",
                      "xmlns:foo" =>"http://flavorjon.es/",
                      "xmlns:baz" =>"http://flavorjon.es/",
                    },
                    reparented.namespaces)
                end
              end
            end

            describe "and a child node with a default namespace not matching the parent's default namespace and a namespace matching a parent namespace but with a different prefix" do
              before do
                @ns = @child.add_namespace(nil, 'http://example.org/')
                @child.namespace = @ns
                @ns2 = @child.add_namespace('baz', 'http://tenderlovemaking.com/')
              end

              it "inserts a node that keeps its namespace" do
                @node.add_child(@child)
                assert reparented = @doc.at('//bar:second', "bar" => "http://example.org/")
                assert reparented.namespace_definitions.include?(@ns)
                assert reparented.namespace_definitions.include?(@ns2)
                assert_equal @ns, reparented.namespace
                assert_equal(
                  {
                    "xmlns"     => "http://example.org/",
                    "xmlns:foo" => "http://flavorjon.es/",
                    "xmlns:baz" => "http://tenderlovemaking.com/",
                  },
                  reparented.namespaces)
              end
            end
          end
        end

        describe "#add_previous_sibling" do
          it "should not merge text nodes during the operation" do
            xml = Nokogiri::XML %Q(<root>text node</root>)
            replacee = xml.root.children.first
            replacee.add_previous_sibling "foo <p></p> bar"
            assert_equal "foo <p></p> bartext node", xml.root.children.to_html
          end

          it 'should remove the child node after the operation' do
            fragment = Nokogiri::HTML::DocumentFragment.parse("a<a>b</a>")
            node = fragment.children.last
            node.add_previous_sibling node.children
            assert_empty node.children, "should have no childrens"
          end

          describe "with a text node before" do
            it "should not defensively dup the 'before' text node" do
              xml = Nokogiri::XML %Q(<root>before<p></p>after</root>)
              pivot  = xml.at_css("p")
              before = xml.root.children.first
              after  = xml.root.children.last
              pivot.add_previous_sibling("x")

              assert_equal "after", after.content
              assert !after.parent.nil?, "unrelated node should not be affected"

              assert_equal "before", before.content
              assert !before.parent.nil?, "no need to reparent"
            end
          end
        end

        describe "#add_next_sibling" do
          it "should not merge text nodes during the operation" do
            xml = Nokogiri::XML %Q(<root>text node</root>)
            replacee = xml.root.children.first
            replacee.add_next_sibling "foo <p></p> bar"
            assert_equal "text nodefoo <p></p> bar", xml.root.children.to_html
          end

          it 'should append a text node before an existing non text node' do
            xml = Nokogiri::XML %Q(<root><p>foo</p><p>bar</p></root>)
            p = xml.at_css 'p'
            p.add_next_sibling 'a'
            assert_equal '<root><p>foo</p>a<p>bar</p></root>', xml.root.to_s
          end

          it 'should append a text node before an existing text node' do
            xml = Nokogiri::XML %Q(<root><p>foo</p>after</root>)
            p = xml.at_css 'p'
            p.add_next_sibling 'x'
            assert_equal '<root><p>foo</p>xafter</root>', xml.root.to_s
          end

          describe "with a text node after" do
            it "should not defensively dup the 'after' text node" do
              xml = Nokogiri::XML %Q(<root>before<p></p>after</root>)
              pivot  = xml.at_css("p")
              before = xml.root.children.first
              after  = xml.root.children.last
              pivot.add_next_sibling("x")

              assert_equal "before", before.content
              assert !before.parent.nil?, "unrelated node should not be affected"

              assert_equal "after", after.content
              assert !after.parent.nil?
            end
          end
        end

        describe "#replace" do
          describe "a text node with a text node" do
            it "should not merge text nodes during the operation" do
              xml = Nokogiri::XML %Q(<root>text node</root>)
              replacee = xml.root.children.first
              replacee.replace "new text node"
              assert_equal "new text node", xml.root.children.first.content
            end
          end

          describe "when a document has a default namespace" do
            before do
              @fruits = Nokogiri::XML(<<-eoxml)
                <fruit xmlns="http://fruits.org">
                  <apple />
                </fruit>
              eoxml
            end

            it "inserts a node with default namespaces" do
              apple = @fruits.css('apple').first

              orange = Nokogiri::XML::Node.new('orange', @fruits)
              apple.replace(orange)

              assert_equal orange, @fruits.css('orange').first
            end
          end
        end

        describe "unlinking a node and then reparenting it" do
          it "not blow up" do
            # see http://github.com/sparklemotion/nokogiri/issues#issue/22
            10.times do
              begin
                doc = Nokogiri::XML <<-EOHTML
                  <root>
                    <a>
                      <b/>
                      <c/>
                    </a>
                  </root>
                EOHTML

                assert root = doc.at("root")
                assert a = root.at("a")
                assert b = a.at("b")
                assert c = a.at("c")
                a.add_next_sibling(b.unlink)
                c.unlink
              end
              GC.start
            end
          end
        end

        describe "replace-merging text nodes" do
          [
            ['<root>a<br/></root>',  'afoo'],
            ['<root>a<br/>b</root>', 'afoob'],
            ['<root><br/>b</root>',  'foob']
          ].each do |xml, result|
            it "doesn't blow up on #{xml}" do
              doc = Nokogiri::XML.parse(xml)
              saved_nodes = doc.root.children
              doc.at_xpath("/root/br").replace(Nokogiri::XML::Text.new('foo', doc))
              saved_nodes.each { |child| child.inspect } # try to cause a crash
              assert_equal result, doc.at_xpath("/root/text()").inner_text
            end
          end
        end

        describe "reparenting into another document" do
          it "correctly sets default namespace of a reparented node" do
            # issue described in #391
            # thanks to Nick Canzoneri @nickcanz for this test case!
            source_doc = Nokogiri::XML <<-EOX
<?xml version="1.0" encoding="utf-8"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
    <Product>
        <Package />
        <Directory Id="TARGETDIR" Name="SourceDir">
            <Component>
                <File />
            </Component>
        </Directory>
    </Product>
</Wix>
EOX

            dest_doc = Nokogiri::XML <<-EOX
<?xml version="1.0" encoding="utf-8"?>
<Wix xmlns='http://schemas.microsoft.com/wix/2006/wi'>
  <Fragment Id='MSIComponents'>
      <DirectoryRef Id='InstallDir'>
      </DirectoryRef>
  </Fragment>
</Wix>
EOX

            stuff = source_doc.at_css("Directory[Id='TARGETDIR']")
            insert_point = dest_doc.at_css("DirectoryRef[Id='InstallDir']")
            insert_point.children = stuff.children()

            assert_no_match(/default:/, insert_point.children.to_xml)
            assert_match(/<Component>/, insert_point.children.to_xml)
          end
        end
      end
    end
  end
end
