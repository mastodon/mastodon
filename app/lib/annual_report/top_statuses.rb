# frozen_string_literal: true

class AnnualReport::TopStatuses < AnnualReport::Source
  def generate
    top_reblogs = base_scope.order(reblogs_count: :desc).first&.id
    top_favourites = base_scope.where.not(id: top_reblogs).order(favourites_count: :desc).first&.id
    top_replies = base_scope.where.not(id: [top_reblogs, top_favourites]).order(replies_count: :desc).first&.id

    {
      top_statuses: {
        by_reblogs: top_reblogs&.to_s,
        by_favourites: top_favourites&.to_s,
        by_replies: top_replies&.to_s,
      },
    }
  end

  def base_scope
    report_statuses.public_visibility.joins(:status_stat)
  end
end
