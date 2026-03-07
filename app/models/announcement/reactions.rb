# frozen_string_literal: true

module Announcement::Reactions
  extend ActiveSupport::Concern

  included do
    has_many :announcement_reactions, dependent: :destroy
  end

  def reactions(account = nil)
    grouped_ordered_announcement_reactions
      .select(reaction_columns_for_account(account))
      .to_a
      .tap { |records| ActiveRecord::Associations::Preloader.new(records: records, associations: :custom_emoji).call }
  end

  private

  def grouped_ordered_announcement_reactions
    announcement_reactions
      .group(:announcement_id, :name, :custom_emoji_id)
      .order(AnnouncementReaction.arel_table[:created_at].minimum.asc)
  end

  def reaction_columns_for_account(account)
    [:name, :custom_emoji_id, Arel.star.count.as('count')]
      .tap { |values| values << reaction_me_column_value(account).as('me') }
  end

  def reaction_me_column_value(account)
    if account.nil?
      Arel.sql 'FALSE'
    else
      Arel.sql(<<~SQL.squish)
        EXISTS(
          SELECT 1
          FROM announcement_reactions inner_reactions
          WHERE inner_reactions.account_id = #{account.id}
            AND inner_reactions.announcement_id = announcement_reactions.announcement_id
            AND inner_reactions.name = announcement_reactions.name
        )
      SQL
    end
  end
end
