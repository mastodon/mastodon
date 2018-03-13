# frozen_string_literal: true

class TagSearchService < BaseService
  def call(query, limit, account = nil)
    scope = Tag.search_for(query.gsub(/\A#/, '').strip)

    recently_used_tags = []
    if account.present?
      recently_used_tags = scope.joins(:recently_used_tags)
                                .merge(account.recently_used_tags.recent)
                                .limit(limit)
    end

    recently_unused_tags = scope.where
                                .not(id: recently_used_tags)
                                .order(:name)
                                .limit(limit - recently_used_tags.size)

    recently_used_tags + recently_unused_tags
  end
end
