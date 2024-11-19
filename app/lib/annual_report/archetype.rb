# frozen_string_literal: true

class AnnualReport::Archetype < AnnualReport::Source
  # Average number of posts (including replies and reblogs) made by
  # each active user in a single year (2023)
  AVERAGE_PER_YEAR = 113

  POLL_WEIGHT = 0.1
  REBLOG_WEIGHT = 2
  REPLY_WEIGHT = 2

  def generate
    {
      archetype: archetype,
    }
  end

  private

  def archetype
    if (standalone_count + replies_count + reblogs_count) < AVERAGE_PER_YEAR
      :lurker
    elsif reblogs_count > (standalone_count * REBLOG_WEIGHT)
      :booster
    elsif polls_count > (standalone_count * POLL_WEIGHT) # standalone_count includes posts with polls
      :pollster
    elsif replies_count > (standalone_count * REPLY_WEIGHT)
      :replier
    else
      :oracle
    end
  end

  def polls_count
    @polls_count ||= report_statuses.where.not(poll_id: nil).count
  end

  def reblogs_count
    @reblogs_count ||= report_statuses.where.not(reblog_of_id: nil).count
  end

  def replies_count
    @replies_count ||= report_statuses.where.not(in_reply_to_id: nil).where.not(in_reply_to_account_id: @account.id).count
  end

  def standalone_count
    @standalone_count ||= report_statuses.without_replies.without_reblogs.count
  end
end
