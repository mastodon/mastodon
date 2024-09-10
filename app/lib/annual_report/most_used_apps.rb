# frozen_string_literal: true

class AnnualReport::MostUsedApps < AnnualReport::Source
  SET_SIZE = 10

  def generate
    {
      most_used_apps: app_map,
    }
  end

  private

  def app_map
    most_used_apps.map do |name, count|
      {
        name: name,
        count: count,
      }
    end
  end

  def most_used_apps
    report_statuses
      .group(Doorkeeper::Application.arel_table[:name])
      .joins(:application)
      .limit(SET_SIZE)
      .order(total: :desc)
      .pluck(Doorkeeper::Application.arel_table[:name], Arel.star.count.as('total'))
  end
end
