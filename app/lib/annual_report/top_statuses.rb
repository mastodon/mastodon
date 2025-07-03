# frozen_string_literal: true

class AnnualReport::TopStatuses < AnnualReport::Source
  def generate
    {
      top_statuses: {
        by_reblogs: most_reblogged_status_id&.to_s,
        by_favourites: most_favourited_status_id&.to_s,
        by_replies: most_replied_status_id&.to_s,
      },
    }
  end

  private

  def most_reblogged_status_id
    most_reblogged_status&.id
  end

  def most_favourited_status_id
    most_favourited_status&.id
  end

  def most_replied_status_id
    most_replied_status&.id
  end

  def most_reblogged_status
    base_scope.order(reblogs_count: :desc).first
  end

  def most_favourited_status
    base_scope.excluding(most_reblogged_status).order(favourites_count: :desc).first
  end

  def most_replied_status
    base_scope.excluding(most_reblogged_status, most_favourited_status).order(replies_count: :desc).first
  end

  def base_scope
    report_statuses.public_visibility.joins(:status_stat)
  end
end
