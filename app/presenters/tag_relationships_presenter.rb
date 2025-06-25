# frozen_string_literal: true

class TagRelationshipsPresenter
  attr_reader :following_map, :featuring_map

  def initialize(tags, current_account_id = nil)
    if current_account_id.nil?
      @following_map = {}
      @featuring_map = {}
    else
      @following_map = mapped_tag_follows(tags, current_account_id)
      @featuring_map = mapped_featured_tags(tags, current_account_id)
    end
  end

  private

  def mapped_tag_follows(tags, account_id)
    TagFollow
      .where(tag_id: tags.map(&:id), account_id: account_id)
      .pluck(:tag_id)
      .index_with(true)
  end

  def mapped_featured_tags(tags, account_id)
    FeaturedTag
      .where(tag_id: tags.map(&:id), account_id: account_id)
      .pluck(:tag_id)
      .index_with(true)
  end
end
