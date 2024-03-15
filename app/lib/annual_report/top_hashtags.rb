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
    Tag.joins(:statuses).where(statuses: { id: @account.statuses.where(id: year_as_snowflake_range).reorder(nil).select(:id) }).group(:id).having('count(*) > 1').order(total: :desc).limit(SET_SIZE).pluck(Arel.sql('COALESCE(tags.display_name, tags.name), count(*) AS total'))
  end
end
