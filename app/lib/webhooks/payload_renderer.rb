# frozen_string_literal: true

class Webhooks::PayloadRenderer
  class DocumentTraverser
    INT_REGEX = /[0-9]+/

    def initialize(document)
      @document = document.with_indifferent_access
    end

    def get(path)
      value  = @document.dig(*parse_path(path))
      string = Oj.dump(value)

      # We want to make sure people can use the variable inside
      # other strings, so it can't be wrapped in quotes.
      if value.is_a?(String)
        string[1...-1]
      else
        string
      end
    end

    private

    def parse_path(path)
      path.split('.').filter_map do |segment|
        if segment.match(INT_REGEX)
          segment.to_i
        else
          segment.presence
        end
      end
    end
  end

  class TemplateParser < Parslet::Parser
    rule(:dot) { str('.') }
    rule(:digit) { match('[0-9]') }
    rule(:property_name) { match('[a-z_]').repeat(1) }
    rule(:array_index) { digit.repeat(1) }
    rule(:segment) { (property_name | array_index) }
    rule(:path) { property_name >> (dot >> segment).repeat }
    rule(:variable) { (str('}}').absent? >> path).repeat.as(:variable) }
    rule(:expression) { str('{{') >> variable >> str('}}') }
    rule(:text) { (str('{{').absent? >> any).repeat(1) }
    rule(:text_with_expressions) { (text.as(:text) | expression).repeat.as(:text) }
    root(:text_with_expressions)
  end

  EXPRESSION_REGEXP = /
    \{\{
      [a-z_]+
      (\.
        ([a-z_]+|[0-9]+)
      )*
    \}\}
  /iox

  def initialize(json)
    @document = DocumentTraverser.new(Oj.load(json))
  end

  def render(template)
    template.gsub(EXPRESSION_REGEXP) { |match| @document.get(match[2...-2]) }
  end
end
