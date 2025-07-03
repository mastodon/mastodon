# frozen_string_literal: true

class AnnualReport::TopStatuses < AnnualReport::Source
  def generate
    most_reblogged_status_id = base_scope.order(reblogs_count: :desc).first&.id
    most_favourited_status_id = base_scope.where.not(id: most_reblogged_status_id).order(favourites_count: :desc).first&.id
    most_replied_status_id = base_scope.where.not(id: [most_reblogged_status_id, most_favourited_status_id]).order(replies_count: :desc).first&.id

    {
      top_statuses: {
        by_reblogs: most_reblogged_status_id&.to_s,
        by_favourites: most_favourited_status_id&.to_s,
        by_replies: most_replied_status_id&.to_s,
      },
    }
  end

  private

  def base_scope
    report_statuses.public_visibility.joins(:status_stat)
  end
end
