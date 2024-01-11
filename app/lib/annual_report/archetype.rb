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
    @polls_count ||= base_scope.where.not(poll_id: nil).count
  end

  def reblogs_count
    @reblogs_count ||= base_scope.where.not(reblog_of_id: nil).count
  end

  def replies_count
    @replies_count ||= base_scope.where.not(in_reply_to_id: nil).where.not(in_reply_to_account_id: @account.id).count
  end

  def standalone_count
    @standalone_count ||= base_scope.without_replies.without_reblogs.count
  end

  def base_scope
    @account.statuses.where(id: year_as_snowflake_range)
  end
end
