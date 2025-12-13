# frozen_string_literal: true

class TagRelationshipsPresenter
  attr_reader :following_map, :featuring_map

  def initialize(tags, current_account_id = nil, **options)
    if current_account_id.nil?
      @following_map = {}
      @featuring_map = {}
    else
      @following_map = TagFollow.select(:tag_id).where(tag_id: tags.map(&:id), account_id: current_account_id).each_with_object({}) { |f, h| h[f.tag_id] = true }.merge(options[:following_map] || {})
      @featuring_map = FeaturedTag.select(:tag_id).where(tag_id: tags.map(&:id), account_id: current_account_id).each_with_object({}) { |f, h| h[f.tag_id] = true }.merge(options[:featuring_map] || {})
    end
  end
end
