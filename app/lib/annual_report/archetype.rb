# frozen_string_literal: true

class AnnualReport::Archetype < AnnualReport::Source
  # Average number of posts (including replies and reblogs) made by
  # each active user in a single year (2023)
  AVERAGE_PER_YEAR = 113

  def generate
    {
      archetype: archetype,
    }
  end

  private

  def archetype
    if (standalone_count + replies_count + reblogs_count) < AVERAGE_PER_YEAR
      :lurker
    elsif reblogs_count > (standalone_count * 2)
      :booster
    elsif polls_count > (standalone_count * 0.1) # standalone_count includes posts with polls
      :pollster
    elsif replies_count > (standalone_count * 2)
      :replier
    else
      :oracle
    end
  end

  def polls_count
    @polls_count ||= report_statuses.only_polls.count
  end

  def reblogs_count
    @reblogs_count ||= report_statuses.only_reblogs.count
  end

  def replies_count
    @replies_count ||= report_statuses.where.not(in_reply_to_id: nil).not_replying_to_account(@account).count
  end

  def standalone_count
    @standalone_count ||= report_statuses.without_replies.without_reblogs.count
  end
end
