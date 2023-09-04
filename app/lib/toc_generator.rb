# frozen_string_literal: true

class TOCGenerator
  TARGET_ELEMENTS = %w(h1 h2 h3 h4 h5 h6).freeze
  LISTED_ELEMENTS = %w(h2 h3).freeze

  class Section
    attr_accessor :depth, :title, :children, :anchor

    def initialize(depth, title, anchor)
      @depth    = depth
      @title    = title
      @children = []
      @anchor   = anchor
    end

    delegate :<<, to: :children
  end

  def initialize(source_html)
    @source_html = source_html
    @processed   = false
    @target_html = ''
    @headers     = []
    @slugs       = Hash.new { |h, k| h[k] = 0 }
  end

  def html
    parse_and_transform unless @processed
    @target_html
  end

  def toc
    parse_and_transform unless @processed
    @headers
  end

  private

  def parse_and_transform
    return if @source_html.blank?

    parsed_html = Nokogiri::HTML.fragment(@source_html)

    parsed_html.traverse do |node|
      next unless TARGET_ELEMENTS.include?(node.name)

      anchor = node['id'] || node.text.parameterize.presence || 'sec'
      @slugs[anchor] += 1
      anchor = "#{anchor}-#{@slugs[anchor]}" if @slugs[anchor] > 1

      node['id'] = anchor

      next unless LISTED_ELEMENTS.include?(node.name)

      depth          = node.name[1..-1]
      latest_section = @headers.last

      if latest_section.nil? || latest_section.depth >= depth
        @headers << Section.new(depth, node.text, anchor)
      else
        latest_section << Section.new(depth, node.text, anchor)
      end
    end

    @target_html = parsed_html.to_s
    @processed   = true
  end
end
