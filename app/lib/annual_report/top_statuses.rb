# frozen_string_literal: true

class AnnualReport::TopStatuses < AnnualReport::Source
  def generate
    {
      top_statuses: {
        by_reblogs: status_identifier(most_reblogged_status),
        by_favourites: nil,
        by_replies: nil,
      },
    }
  end

  def eligible?
    report_statuses.distributable_visibility.exists?
  end

  private

  def status_identifier(status)
    status.id.to_s if status.present?
  end

  def most_reblogged_status
    base_scope
      .order(reblogs_count: :desc)
      .first
  end

  def most_favourited_status
    base_scope
      .excluding(most_reblogged_status)
      .order(favourites_count: :desc)
      .first
  end

  def most_replied_status
    base_scope
      .excluding(most_reblogged_status, most_favourited_status)
      .order(replies_count: :desc)
      .first
  end

  def base_scope
    report_statuses
      .distributable_visibility
      .joins(:status_stat)
  end
end
