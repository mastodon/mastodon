# frozen_string_literal: true

module Status::Mappings
  extend ActiveSupport::Concern

  class_methods do
    def bookmarks_map(status_ids, account_id)
      Bookmark
        .where(status_id: status_ids, account_id: account_id)
        .pluck(:status_id)
        .index_with(true)
    end

    def favourites_map(status_ids, account_id)
      Favourite
        .where(status_id: status_ids, account_id: account_id)
        .pluck(:status_id)
        .index_with(true)
    end

    def mutes_map(conversation_ids, account_id)
      ConversationMute
        .where(conversation_id: conversation_ids, account_id: account_id)
        .pluck(:conversation_id)
        .index_with(true)
    end

    def pins_map(status_ids, account_id)
      StatusPin
        .where(status_id: status_ids, account_id: account_id)
        .pluck(:status_id)
        .index_with(true)
    end

    def reblogs_map(status_ids, account_id)
      Status
        .unscoped
        .where(reblog_of_id: status_ids, account_id: account_id)
        .pluck(:reblog_of_id)
        .index_with(true)
    end
  end
end
