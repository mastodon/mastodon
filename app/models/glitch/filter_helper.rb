class Glitch::FilterHelper
  include ActionView::Helpers::SanitizeHelper

  attr_reader :text_matcher
  attr_reader :tag_matcher

  def initialize(receiver_id)
    @text_matcher = Glitch::KeywordMute.text_matcher_for(receiver_id)
    @tag_matcher  = Glitch::KeywordMute.tag_matcher_for(receiver_id)
  end

  def matches?(status)
    matchers_match?(status) || (status.reblog? && matchers_match?(status.reblog))
  end

  private

  def matchers_match?(status)
    text_matcher.matches?(strip_tags(status.text)) ||
      text_matcher.matches?(strip_tags(status.spoiler_text)) ||
      tag_matcher.matches?(status.tags)
  end
end
