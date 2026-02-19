# frozen_string_literal: true

class AnnualReport::TopHashtags < AnnualReport::Source
  MINIMUM_TAGGINGS = 1
  SET_SIZE = 1

  def generate
    {
      top_hashtags: top_hashtags.map do |(name, count)|
                      {
                        name: name,
                        count: count,
                      }
                    end,
    }
  end

  def eligible?
    report_statuses.joins(:tags).exists?
  end

  private

  def top_hashtags
    Tag.joins(:statuses).where(statuses: { id: report_statuses.select(:id) }).group(coalesced_tag_names).having(minimum_taggings_count).order(count_all: :desc).limit(SET_SIZE).count
  end

  def minimum_taggings_count
    Arel.star.count.gt(MINIMUM_TAGGINGS)
  end

  def coalesced_tag_names
    Arel.sql(<<~SQL.squish)
      COALESCE(tags.display_name, tags.name)
    SQL
  end
end
