# frozen_string_literal: true

class AnnualReport::TopStatuses < AnnualReport::Source
  def generate
    {
      top_statuses: {
        by_reblogs: top_reblog_status_id.to_s,
        by_favourites: top_favourite_status_id.to_s,
        by_replies: top_reply_status_id.to_s,
      },
    }
  end

  private

  def top_reblog_status_id
    @top_reblog_status_id ||= statuses_by_reblog_count.pick(:id)
  end

  def top_favourite_status_id
    @top_favourite_status_id ||= statuses_by_favourite_count.where.not(id: top_reblog_status_id).pick(:id)
  end

  def top_reply_status_id
    @top_reply_status_id ||= statuses_by_replies_count.where.not(id: [top_reblog_status_id, top_favourite_status_id]).pick(:id)
  end

  def statuses_by_reblog_count
    public_statuses.order(reblogs_count: :desc)
  end

  def statuses_by_favourite_count
    public_statuses.order(favourites_count: :desc)
  end

  def statuses_by_replies_count
    public_statuses.order(replies_count: :desc)
  end

  def public_statuses
    report_statuses.public_visibility.joins(:status_stat)
  end
end
