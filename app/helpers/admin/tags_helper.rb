# frozen_string_literal: true

module Admin::TagsHelper
  def admin_tags_moderation_options
    [
      [t('admin.tags.moderation.reviewed'), 'reviewed'],
      [t('admin.tags.moderation.review_requested'), 'review_requested'],
      [t('admin.tags.moderation.unreviewed'), 'unreviewed'],
      [t('admin.tags.moderation.trendable'), 'trendable'],
      [t('admin.tags.moderation.not_trendable'), 'not_trendable'],
      [t('admin.tags.moderation.usable'), 'usable'],
      [t('admin.tags.moderation.not_usable'), 'not_usable'],
    ]
  end
end
