# frozen_string_literal: true

class AnnualReport::Archetype < AnnualReport::Source
  # Average number of posts (including replies and reblogs) made by
  # each active user in a single year (2023)
  AVERAGE_PER_YEAR = 113

  SCORE_MULTIPLIER = 2
  SCORE_REDUCER = 0.1

  def generate
    {
      archetype: archetype,
    }
  end

  private

  def archetype
    if (standalone_count + replies_count + reblogs_count) < AVERAGE_PER_YEAR
      :lurker
    elsif reblogs_count > (standalone_count * SCORE_MULTIPLIER)
      :booster
    elsif polls_count > (standalone_count * SCORE_REDUCER) # standalone_count includes posts with polls
      :pollster
    elsif replies_count > (standalone_count * SCORE_MULTIPLIER)
      :replier
    else
      :oracle
    end
  end

  def polls_count
    @polls_count ||= report_statuses.with_polls.count
  end

  def reblogs_count
    @reblogs_count ||= report_statuses.with_reblogs.count
  end

  def replies_count
    @replies_count ||= report_statuses.with_replies.without_replies_to(@account).count
  end

  def standalone_count
    @standalone_count ||= report_statuses.without_replies.without_reblogs.count
  end
end
