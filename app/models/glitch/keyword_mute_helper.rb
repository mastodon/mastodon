require 'html2text'

class Glitch::KeywordMuteHelper
  attr_reader :text_matcher
  attr_reader :tag_matcher

  def initialize(receiver_id)
    @text_matcher   = Glitch::KeywordMute.text_matcher_for(receiver_id)
    @tag_matcher    = Glitch::KeywordMute.tag_matcher_for(receiver_id)
  end

  def matches?(status, scope)
    matchers_match?(status, scope) || (status.reblog? && matchers_match?(status.reblog, scope))
  end

  private

  def matchers_match?(status, scope)
    text_matcher.matches?(prepare_text(status.text), scope) ||
      text_matcher.matches?(prepare_text(status.spoiler_text), scope) ||
      tag_matcher.matches?(status.tags, scope)
  end

  def prepare_text(text)
    Html2Text.convert(text)
  end
end
