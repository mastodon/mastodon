# frozen_string_literal: true
require 'tilt'

module Hamlit
  class Filters
    class TiltBase < Base
      def self.render(name, source, indent_width: 0)
        text = ::Tilt["t.#{name}"].new { source }.render
        return text if indent_width == 0
        text.gsub!(/^/, ' ' * indent_width)
      end

      def explicit_require?(needed_registration)
        Gem::Version.new(Tilt::VERSION) >= Gem::Version.new('2.0.0') &&
          !Tilt.registered?(needed_registration)
      end

      private

      def compile_with_tilt(node, name, indent_width: 0)
        if ::Hamlit::HamlUtil.contains_interpolation?(node.value[:text])
          dynamic_compile(node, name, indent_width: indent_width)
        else
          static_compile(node, name, indent_width: indent_width)
        end
      end

      def static_compile(node, name, indent_width: 0)
        temple = [:multi, [:static, TiltBase.render(name, node.value[:text], indent_width: indent_width)]]
        node.value[:text].split("\n").size.times do
          temple << [:newline]
        end
        temple
      end

      def dynamic_compile(node, name, indent_width: 0)
        # original: Haml::Filters#compile
        text = ::Hamlit::HamlUtil.slow_unescape_interpolation(node.value[:text]).gsub(/(\\+)n/) do |s|
          escapes = $1.size
          next s if escapes % 2 == 0
          "#{'\\' * (escapes - 1)}\n"
        end
        text.prepend("\n").sub!(/\n"\z/, '"')

        [:dynamic, "::Hamlit::Filters::TiltBase.render('#{name}', #{text}, indent_width: #{indent_width})"]
      end
    end
  end
end
