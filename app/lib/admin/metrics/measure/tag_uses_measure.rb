# frozen_string_literal: true

class Admin::Metrics::Measure::TagUsesMeasure < Admin::Metrics::Measure::BaseMeasure
  def key
    'tag_uses'
  end

  def total
    tag.history.aggregate(time_period).uses
  end

  def previous_total
    tag.history.aggregate(previous_time_period).uses
  end

  def data
    time_period.map { |date| { date: date.to_time(:utc).iso8601, value: tag.history.get(date).uses.to_s } }
  end

  protected

  def tag
    @tag ||= Tag.find(params[:id])
  end

  def time_period
    (@start_at.to_date..@end_at.to_date)
  end

  def previous_time_period
    ((@start_at.to_date - length_of_period)..(@end_at.to_date - length_of_period))
  end

  def params
    @params.permit(:id)
  end
end
