# -*- coding: utf-8 -*-

require "helper"

module Nokogiri
  module XML
    class TestBuilder < Nokogiri::TestCase
      def test_attribute_sensitivity
        xml = Nokogiri::XML::Builder.new { |x|
          x.tag "hello", "abcDef" => "world"
        }.to_xml
        doc = Nokogiri.XML xml
        assert_equal 'world', doc.root['abcDef']
      end

      def test_builder_multiple_nodes
        Nokogiri::XML::Builder.new do |xml|
          0.upto(10) do
            xml.text "test"
          end
        end
      end


      def test_builder_with_utf8_text
        text = "test ﺵ "
        doc = Nokogiri::XML::Builder.new(:encoding => "UTF-8") { |xml| xml.test text }.doc
        assert_equal text, doc.content
      end

      def test_builder_escape
        xml = Nokogiri::XML::Builder.new { |x|
          x.condition "value < 1", :attr => "value < 1"
        }.to_xml
        doc = Nokogiri.XML xml
        assert_equal 'value < 1', doc.root['attr']
        assert_equal 'value < 1', doc.root.content
      end

      def test_builder_namespace
        doc = Nokogiri::XML::Builder.new { |xml|
          xml.a("xmlns:a" => "x") do
            xml.b("xmlns:a" => "x", "xmlns:b" => "y")
          end
        }.doc

        b = doc.at('b')
        assert b
        assert_equal({"xmlns:a"=>"x", "xmlns:b"=>"y"}, b.namespaces)
        assert_equal({"xmlns:b"=>"y"}, namespaces_defined_on(b))
      end

      def test_builder_namespace_part_deux
        doc = Nokogiri::XML::Builder.new { |xml|
          xml.a("xmlns:b" => "y") do
            xml.b("xmlns:a" => "x", "xmlns:b" => "y", "xmlns:c" => "z")
          end
        }.doc

        b = doc.at('b')
        assert b
        assert_equal({"xmlns:a"=>"x", "xmlns:b"=>"y", "xmlns:c"=>"z"}, b.namespaces)
        assert_equal({"xmlns:a"=>"x", "xmlns:c"=>"z"}, namespaces_defined_on(b))
      end

      def test_builder_with_unlink
        b = Nokogiri::XML::Builder.new do |xml|
          xml.foo do
            xml.bar { xml.parent.unlink }
            xml.bar2
          end
        end
        assert b
      end

      def test_with_root
        doc = Nokogiri::XML(File.read(XML_FILE))
        Nokogiri::XML::Builder.with(doc.at('employee')) do |xml|
          xml.foo
        end
        assert_equal 1, doc.xpath('//employee/foo').length
      end

      def test_root_namespace_default_decl
        b = Nokogiri::XML::Builder.new { |xml| xml.root(:xmlns => 'one:two') }
        doc = b.doc
        assert_equal 'one:two', doc.root.namespace.href
        assert_equal({ 'xmlns' => 'one:two' }, doc.root.namespaces)
      end

      def test_root_namespace_multi_decl
        b = Nokogiri::XML::Builder.new { |xml|
          xml.root(:xmlns => 'one:two', 'xmlns:foo' => 'bar') do
            xml.hello
          end
        }
        doc = b.doc
        assert_equal 'one:two', doc.root.namespace.href
        assert_equal({ 'xmlns' => 'one:two', 'xmlns:foo' => 'bar' }, doc.root.namespaces)

        assert_equal 'one:two', doc.at('hello').namespace.href
      end

      def test_non_root_namespace
        b = Nokogiri::XML::Builder.new { |xml|
          xml.root { xml.hello(:xmlns => 'one') }
        }
        assert_equal 'one', b.doc.at('hello', 'xmlns' => 'one').namespace.href
      end

      def test_specify_namespace
        b = Nokogiri::XML::Builder.new { |xml|
          xml.root('xmlns:foo' => 'bar') do
            xml[:foo].bar
            xml['foo'].baz
          end
        }
        doc = b.doc
        assert_equal 'bar', doc.at('foo|bar', 'foo' => 'bar').namespace.href
        assert_equal 'bar', doc.at('foo|baz', 'foo' => 'bar').namespace.href
      end

      def test_dtd_in_builder_output
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.doc.create_internal_subset(
                                         'html',
                                         "-//W3C//DTD HTML 4.01 Transitional//EN",
                                         "http://www.w3.org/TR/html4/loose.dtd"
                                         )
          xml.root do
            xml.foo
          end
        end
        assert_match(/<!DOCTYPE html PUBLIC "-\/\/W3C\/\/DTD HTML 4.01 Transitional\/\/EN" "http:\/\/www.w3.org\/TR\/html4\/loose.dtd">/,
                     builder.to_xml)
      end

      def test_specify_namespace_nested
        b = Nokogiri::XML::Builder.new { |xml|
          xml.root('xmlns:foo' => 'bar') do
            xml.yay do
              xml[:foo].bar

              xml.yikes do
                xml['foo'].baz
              end
            end
          end
        }
        doc = b.doc
        assert_equal 'bar', doc.at('foo|bar', 'foo' => 'bar').namespace.href
        assert_equal 'bar', doc.at('foo|baz', 'foo' => 'bar').namespace.href
      end

      def test_specified_namespace_postdeclared
        doc = Nokogiri::XML::Builder.new { |xml|
          xml.a do
            xml[:foo].b("xmlns:foo" => "bar")
          end
        }.doc
        a = doc.at('a')
        assert_equal({}, a.namespaces)

        b = doc.at_xpath('//foo:b', {:foo=>'bar'})
        assert b
        assert_equal({"xmlns:foo"=>"bar"}, b.namespaces)
        assert_equal("b", b.name)
        assert_equal("bar", b.namespace.href)
      end

      def test_specified_namespace_undeclared
        Nokogiri::XML::Builder.new { |xml|
          xml.root do
            assert_raises(ArgumentError) do
              xml[:foo].bar
            end
          end
        }
      end

      def test_set_encoding
        builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.root do
            xml.bar 'blah'
          end
        end
        assert_match 'UTF-8', builder.to_xml
      end

      def test_bang_and_underscore_is_escaped
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.root do
            xml.p_('adsfadsf')
            xml.p!('adsfadsf')
          end
        end
        assert_equal 2, builder.doc.xpath('//p').length
      end

      def test_square_brackets_set_attributes
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.root do
            foo = xml.foo
            foo['id'] = 'hello'
            assert_equal 'hello', foo['id']
          end
        end
        assert_equal 1, builder.doc.xpath('//foo[@id = "hello"]').length
      end

      def test_nested_local_variable
        @ivar     = 'hello'
        local_var = 'hello world'
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.root do
            xml.foo local_var
            xml.bar @ivar
            xml.baz {
              xml.text @ivar
            }
          end
        end

        assert_equal 'hello world', builder.doc.at('//root/foo').content
        assert_equal 'hello', builder.doc.at('//root/bar').content
        assert_equal 'hello', builder.doc.at('baz').content
      end

      def test_raw_append
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.root do
            xml << 'hello'
          end
        end

        assert_equal 'hello', builder.doc.at('/root').content
      end

      def test_raw_append_with_instance_eval
        builder = Nokogiri::XML::Builder.new do
          root do
            self << 'hello'
          end
        end

        assert_equal 'hello', builder.doc.at('/root').content
      end

      def test_raw_xml_append
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.root do
            xml << '<aaa><bbb/><ccc/></aaa>'
          end
        end

        assert_equal ["aaa"],       builder.doc.at_css("root").children.collect(&:name)
        assert_equal ["bbb","ccc"], builder.doc.at_css("aaa").children.collect(&:name)
      end

      def test_raw_xml_append_with_namespaces
        doc = Nokogiri::XML::Builder.new do |xml|
          xml.root("xmlns:foo" => "x", "xmlns" => "y") do
            xml << '<Element foo:bar="bazz"/>'
          end
        end.doc

        el = doc.at 'Element'
        assert_not_nil el

        assert_equal 'y', el.namespace.href
        assert_nil el.namespace.prefix

        attr = el.attributes["bar"]
        assert_not_nil attr
        assert_not_nil attr.namespace
        assert_equal "foo", attr.namespace.prefix
      end

      def test_cdata
        builder = Nokogiri::XML::Builder.new do
          root {
            cdata "hello world"
          }
        end
        assert_equal("<?xml version=\"1.0\"?><root><![CDATA[hello world]]></root>",
          builder.to_xml.gsub(/\n/, ""))
      end

      def test_comment
        builder = Nokogiri::XML::Builder.new do
          root {
            comment "this is a comment"
          }
        end
        assert builder.doc.root.children.first.comment?
      end

      def test_builder_no_block
        string = "hello world"
        builder = Nokogiri::XML::Builder.new
        builder.root {
          cdata string
        }
        assert_equal("<?xml version=\"1.0\"?><root><![CDATA[hello world]]></root>",
          builder.to_xml.gsub(/\n/, ''))
      end

      def test_builder_can_inherit_parent_namespace
        builder = Nokogiri::XML::Builder.new
        builder.products {
          builder.parent.default_namespace = "foo"
          builder.product {
            builder.parent.default_namespace = nil
          }
        }
        doc = builder.doc
        ['product', 'products'].each do |n|
          assert_equal doc.at_xpath("//*[local-name() = '#{n}']").namespace.href, 'foo'
        end
      end

      def test_builder_can_handle_namespace_override
        builder = Nokogiri::XML::Builder.new
        builder.products('xmlns:foo' => 'bar') {
          builder.product('xmlns:foo' => 'baz')
        }

        doc = builder.doc
        assert_equal doc.at_xpath("//*[local-name() = 'product']").namespaces['xmlns:foo'], 'baz'
        assert_equal doc.at_xpath("//*[local-name() = 'products']").namespaces['xmlns:foo'], 'bar'
        assert_nil doc.at_xpath("//*[local-name() = 'products']").namespace
      end

      private

      def namespaces_defined_on(node)
        Hash[*node.namespace_definitions.collect{|n| ["xmlns:" + n.prefix, n.href]}.flatten]
      end
    end
  end
end
