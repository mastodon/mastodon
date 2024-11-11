# frozen_string_literal: true

class MoveTagTrendsToTable < ActiveRecord::Migration[7.2]
  include Redisable

  disable_ddl_transaction!

  def up
    redis.zrange('trending_tags:all', 0, -1, with_scores: true).each do |(tag_id, score)|
      TagTrend.create(
        tag_id: tag_id,
        score: score,
        allowed: redis.zscore('trending_tags:allowed', tag_id).present?
      )
    end

    TagTrend.recalculate_ordered_rank

    redis.del('trending_tags:allowed', 'trending_tags:all')
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
