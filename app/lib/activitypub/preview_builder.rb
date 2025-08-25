# frozen_string_literal: true

class ActivityPub::PreviewBuilder
  include FormattingHelper

  def initialize(parser)
    @parser = parser
  end

  def text
    [title, summary, url].compact.join("\n\n")
  end

  private

  def title
    "<h2>#{@parser.title}</h2>" if @parser.title.present?
  end

  def summary
    @parser.spoiler_text
  end

  def url
    linkify(@parser.url || @parser.uri)
  end
end
