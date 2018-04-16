require 'test_helper'
require 'tilt'

begin
  require 'tilt/asciidoc'

  class AsciidoctorTemplateTest < Minitest::Test
    HTML5_OUTPUT = "<div class=\"sect1\"><h2 id=\"_hello_world\">Hello World!</h2><div class=\"sectionbody\"></div></div>"
    DOCBOOK45_OUTPUT = "<section id=\"_hello_world\"><title>Hello World!</title></section>"
    DOCBOOK5_OUTPUT = "<section xml:id=\"_hello_world\"><title>Hello World!</title></section>"

    def strip_space(str)
      str.gsub(/>\s+</, '><').strip
    end

    test "registered for '.ad' files" do
      assert_equal Tilt::AsciidoctorTemplate, Tilt['ad']
    end

    test "registered for '.adoc' files" do
      assert_equal Tilt::AsciidoctorTemplate, Tilt['adoc']
    end

    test "registered for '.asciidoc' files" do
      assert_equal Tilt::AsciidoctorTemplate, Tilt['asciidoc']
    end

    test "preparing and evaluating html5 templates on #render" do
      template = Tilt::AsciidoctorTemplate.new(:attributes => {"backend" => 'html5'}) { |t| "== Hello World!" } 
      assert_equal HTML5_OUTPUT, strip_space(template.render)
    end

    test "preparing and evaluating docbook 4.5 templates on #render" do
      template = Tilt::AsciidoctorTemplate.new(:attributes => {"backend" => 'docbook45'}) { |t| "== Hello World!" }
      assert_equal DOCBOOK45_OUTPUT, strip_space(template.render)
    end

    test "preparing and evaluating docbook 5 templates on #render" do
      template = Tilt::AsciidoctorTemplate.new(:attributes => {"backend" => 'docbook5'}) { |t| "== Hello World!" }
      assert_equal DOCBOOK5_OUTPUT, strip_space(template.render)
    end

    test "can be rendered more than once" do
      template = Tilt::AsciidoctorTemplate.new(:attributes => {"backend" => 'html5'}) { |t| "== Hello World!" } 
      3.times { assert_equal HTML5_OUTPUT, strip_space(template.render) }
    end
  end
rescue LoadError
  warn "Tilt::AsciidoctorTemplate (disabled)"
end
