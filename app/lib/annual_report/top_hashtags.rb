# frozen_string_literal: true

class AnnualReport::TopHashtags < AnnualReport::Source
  SET_SIZE = 40
  MINIMUM_COUNT = 1

  def generate
    {
      top_hashtags: hashtag_map,
    }
  end

  private

  def hashtag_map
    top_hashtags.map do |name, count|
      {
        name: name,
        count: count,
      }
    end
  end

  def top_hashtags
    Tag
      .joins(:statuses)
      .where(statuses: { id: report_status_ids })
      .group(:id)
      .having(Arel.star.count.gt(MINIMUM_COUNT))
      .limit(SET_SIZE)
      .order(total: :desc)
      .pluck(coalesced_name, Arel.star.count.as('total'))
  end

  def report_status_ids
    report_statuses.select(:id)
  end

  def coalesced_name
    Arel.sql(<<~SQL.squish)
      COALESCE(tags.display_name, tags.name)
    SQL
  end
end
