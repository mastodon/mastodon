require "helper"

module Nokogiri
  module XML
    class TestDTD < Nokogiri::TestCase
      def setup
        super
        @xml = Nokogiri::XML(File.open(XML_FILE))
        assert @dtd = @xml.internal_subset
      end

      def test_system_id
        assert_equal 'staff.dtd', @dtd.system_id
      end

      def test_external_id
        xml = Nokogiri::XML('<!DOCTYPE foo PUBLIC "bar" ""><foo />')
        assert dtd = xml.internal_subset, 'no internal subset'
        assert_equal 'bar', dtd.external_id
      end

      def test_html_dtd
        {
          'MathML 2.0' => [
            '<!DOCTYPE math PUBLIC "-//W3C//DTD MathML 2.0//EN" "http://www.w3.org/Math/DTD/mathml2/mathml2.dtd">',
            false,
            false,
          ],
          'HTML 2.0' => [
            '<!DOCTYPE html PUBLIC "-//IETF//DTD HTML 2.0//EN">',
            true,
            false,
          ],
          'HTML 3.2' => [
            '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">',
            true,
            false,
          ],
          'XHTML Basic 1.0' => [
            '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.0//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd">',
            true,
            false,
          ],
          'XHTML 1.0 Strict' => [
            '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
            true,
            false,
          ],
          'XHTML + MathML + SVG Profile (XHTML as the host language)' => [
            '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1 plus MathML 2.0 plus SVG 1.1//EN" "http://www.w3.org/2002/04/xhtml-math-svg/xhtml-math-svg.dtd">',
            true,
            false,
          ],
          'XHTML + MathML + SVG Profile (Using SVG as the host)' => [
            '<!DOCTYPE svg:svg PUBLIC "-//W3C//DTD XHTML 1.1 plus MathML 2.0 plus SVG 1.1//EN" "http://www.w3.org/2002/04/xhtml-math-svg/xhtml-math-svg.dtd">',
            false,
            false,
          ],
          'CHTML 1.0' => [
            '<!DOCTYPE HTML PUBLIC "-//W3C//DTD Compact HTML 1.0 Draft//EN">',
            true,
            false,
          ],
          'HTML 4.01 Strict' => [
            '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">',
            true,
            false,
          ],
          'HTML 4.01 Transitional' => [
            '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">',
            true,
            false,
          ],
          'HTML 4.01 Frameset' => [
            '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">',
            true,
            false,
          ],
          'HTML 5' => [
            '<!DOCTYPE html>',
            true,
            true,
          ],
          'HTML 5 legacy compatible' => [
            '<!DOCTYPE HTML SYSTEM "about:legacy-compat">',
            true,
            true,
          ],
        }.each { |name, (dtd_str, html_p, html5_p)|
          doc = Nokogiri(dtd_str)
          dtd = doc.internal_subset
          assert_instance_of Nokogiri::XML::DTD, dtd, name
          if html_p
            assert_send [dtd, :html_dtd?], name
          else
            assert_not_send [dtd, :html_dtd?], name
          end
          if html5_p
            assert_send [dtd, :html5_dtd?], name
          else
            assert_not_send [dtd, :html5_dtd?], name
          end
        }
      end

      def test_content
        assert_raise NoMethodError do
          @dtd.content
        end
      end

      def test_empty_attributes
        dtd = Nokogiri::HTML("<html></html>").internal_subset
        assert_equal Hash.new, dtd.attributes
      end

      def test_attributes
        assert_equal ['width'], @dtd.attributes.keys
        assert_equal '0', @dtd.attributes['width'].default
      end

      def test_keys
        assert_equal ['width'], @dtd.keys
      end

      def test_each
        hash = {}
        @dtd.each { |key, value| hash[key] = value }
        assert_equal @dtd.attributes, hash
      end

      def test_namespace
        assert_raise NoMethodError do
          @dtd.namespace
        end
      end

      def test_namespace_definitions
        assert_raise NoMethodError do
          @dtd.namespace_definitions
        end
      end

      def test_line
        assert_raise NoMethodError do
          @dtd.line
        end
      end

      def test_validate
        if Nokogiri.uses_libxml?
          list = @xml.internal_subset.validate @xml
          assert_equal 44, list.length
        else
          xml = Nokogiri::XML(File.open(XML_FILE)) {|cfg| cfg.dtdvalid}
          list = xml.internal_subset.validate xml
          assert_equal 40, list.length
        end
      end

      def test_external_subsets
        assert subset = @xml.internal_subset
        assert_equal 'staff', subset.name
      end

      def test_entities
        assert entities = @dtd.entities
        assert_equal %w[ ent1 ent2 ent3 ent4 ent5 ].sort, entities.keys.sort
      end

      def test_elements
        assert elements = @dtd.elements
        assert_equal %w[ br ], elements.keys
        assert_equal 'br', elements['br'].name
      end

      def test_notations
        assert notations = @dtd.notations
        assert_equal %w[ notation1 notation2 ].sort, notations.keys.sort
        assert notation1 = notations['notation1']
        assert_equal 'notation1', notation1.name
        assert_equal 'notation1File', notation1.public_id
        assert_nil notation1.system_id
      end
    end
  end
end
