# frozen_string_literal: true

class Admin::DashboardPresenter
  attr_reader :counts

  def initialize
    @counts = populate_counts
  end

  def pending_appeals_count
    counts[:appeals].value
  end

  def pending_reports_count
    counts[:reports].value
  end

  def pending_tags_count
    counts[:tags].value
  end

  def pending_users_count
    counts[:users].value
  end

  private

  def populate_counts
    {
      appeals: Appeal.pending.async_count,
      reports: Report.unresolved.async_count,
      tags: Tag.pending_review.async_count,
      users: User.pending.async_count,
    }
  end
end
