# frozen_string_literal: true

class AnnualReport::MostUsedApps < AnnualReport::Source
  SET_SIZE = 10

  def generate
    {
      most_used_apps: most_used_apps.map do |(name, count)|
                        {
                          name: name,
                          count: count,
                        }
                      end,
    }
  end

  private

  def most_used_apps
    report_statuses.joins(:application).group(oauth_applications: [:name]).order(count_all: :desc).limit(SET_SIZE).count
  end
end
