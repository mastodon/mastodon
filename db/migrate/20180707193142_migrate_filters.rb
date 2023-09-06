# frozen_string_literal: true

class MigrateFilters < ActiveRecord::Migration[5.2]
  class GlitchKeywordMute < ApplicationRecord
    # Dummy class, as we removed Glitch::KeywordMute
    belongs_to :account, optional: false
    validates_presence_of :keyword
  end

  class CustomFilter < ApplicationRecord
    # Dummy class, in case CustomFilter gets altered in the future
    belongs_to :account
    validates :phrase, :context, presence: true

    before_validation :clean_up_contexts

    private

    def clean_up_contexts
      self.context = Array(context).map(&:strip).filter_map(&:presence)
    end
  end

  disable_ddl_transaction!

  def up
    GlitchKeywordMute.find_each do |filter|
      filter.account.custom_filters.create!(
        phrase: filter.keyword,
        context: filter.apply_to_mentions ? %w(home public notifications) : %w(home public),
        whole_word: filter.whole_word,
        irreversible: true
      )
    end
  end

  def down
    unless table_exists? :glitch_keyword_mutes
      create_table :glitch_keyword_mutes do |t|
        t.references :account, null: false
        t.string :keyword, null: false
        t.boolean :whole_word, default: true, null: false
        t.boolean :apply_to_mentions, default: true, null: false
        t.timestamps
      end

      safety_assured { add_foreign_key :glitch_keyword_mutes, :accounts, on_delete: :cascade }
    end

    CustomFilter.where(irreversible: true).find_each do |filter|
      GlitchKeywordMute.where(account: filter.account).create!(
        keyword: filter.phrase,
        whole_word: filter.whole_word,
        apply_to_mentions: filter.context.include?('notifications')
      )
    end
  end
end
