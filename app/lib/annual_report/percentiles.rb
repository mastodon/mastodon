# frozen_string_literal: true

class AnnualReport::Percentiles < AnnualReport::Source
  def self.prepare(year)
    AnnualReport::StatusesPerAccountCount.refresh(year)
  end

  def generate
    {
      percentiles: {
        statuses: 100.0 - ((total_with_fewer_statuses / (total_with_any_statuses + 1.0)) * 100),
      },
    }
  end

  private

  def statuses_created
    @statuses_created ||= report_statuses.count
  end

  def total_with_fewer_statuses
    @total_with_fewer_statuses ||= AnnualReport::StatusesPerAccountCount.where(year: year).where(statuses_count: ...statuses_created).count
  end

  def total_with_any_statuses
    @total_with_any_statuses ||= AnnualReport::StatusesPerAccountCount.where(year: year).count
  end
end
