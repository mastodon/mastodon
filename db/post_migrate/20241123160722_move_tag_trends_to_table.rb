# frozen_string_literal: true

class MoveTagTrendsToTable < ActiveRecord::Migration[7.2]
  include Redisable

  disable_ddl_transaction!

  def up
    redis.zrange('trending_tags:all', 0, -1, with_scores: true).each_slice(1_000) do |data|
      TagTrend.upsert_all(data.map { |(tag_id, score)| { tag_id: tag_id, score: score, language: '', allowed: redis.zscore('trending_tags:allowed', tag_id).present? } }, unique_by: %w(tag_id language))
    end

    TagTrend.recalculate_ordered_rank

    redis.del('trending_tags:allowed', 'trending_tags:all')
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
