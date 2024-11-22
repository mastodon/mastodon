# frozen_string_literal: true

class AnnualReport::TopHashtags < AnnualReport::Source
  SET_SIZE = 40

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

  private

  def top_hashtags
    Tag.joins(:statuses).where(statuses: { id: report_statuses.select(:id) }).group(coalesced_tag_names).having('count(*) > 1').order(count_all: :desc).limit(SET_SIZE).count
  end

  def coalesced_tag_names
    Arel.sql(<<~SQL.squish)
      COALESCE(tags.display_name, tags.name)
    SQL
  end
end
