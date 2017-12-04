require 'htmlentities'

class Glitch::KeywordMuteHelper
  include ActionView::Helpers::SanitizeHelper

  attr_reader :text_matcher
  attr_reader :tag_matcher
  attr_reader :entity_decoder

  def initialize(receiver_id)
    @text_matcher   = Glitch::KeywordMute.text_matcher_for(receiver_id)
    @tag_matcher    = Glitch::KeywordMute.tag_matcher_for(receiver_id)
    @entity_decoder = HTMLEntities.new
  end

  def matches?(status)
    matchers_match?(status) || (status.reblog? && matchers_match?(status.reblog))
  end

  private

  def matchers_match?(status)
    text_matcher.matches?(prepare_text(status.text)) ||
      text_matcher.matches?(prepare_text(status.spoiler_text)) ||
      tag_matcher.matches?(status.tags)
  end

  def prepare_text(text)
    entity_decoder.decode(strip_tags(text)).tap { |x| puts x }
  end
end
