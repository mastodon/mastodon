# frozen_string_literal: true

class Antispam
  include Redisable

  ACCOUNT_AGE_EXEMPTION = 1.week.freeze

  class DummyStatus < SimpleDelegator
    def self.model_name
      Mention.model_name
    end

    def active_mentions
      # Don't use the scope but the in-memory array
      mentions.filter { |mention| !mention.silent? }
    end
  end

  class SilentlyDrop < StandardError
    attr_reader :status

    def initialize(status)
      super()

      status.created_at = Time.now.utc
      status.id = Mastodon::Snowflake.id_at(status.created_at)
      status.in_reply_to_account_id = status.thread&.account_id

      status.delete # Make sure this is not persisted

      @status = DummyStatus.new(status)
    end
  end

  def initialize(status)
    @status = status
  end

  def local_preflight_check!
    return unless considered_spam?

    report_if_needed!

    raise SilentlyDrop, @status
  end

  private

  def considered_spam?
    (all_time_suspicious? || recent_suspicious?) && suspicious_reply_or_mention?
  end

  def all_time_suspicious?
    all_time_spammy_texts.any? { |spammy_text| status_text.include?(spammy_text) }
  end

  def recent_suspicious?
    @status.account.created_at >= ACCOUNT_AGE_EXEMPTION.ago && spammy_texts.any? { |spammy_text| status_text.include?(spammy_text) }
  end

  def spammy_texts
    redis.smembers('antispam:spammy_texts')
  end

  def all_time_spammy_texts
    redis.smembers('antispam:all_time_spammy_texts')
  end

  def suspicious_reply_or_mention?
    account_ids = ([@status.in_reply_to_account_id] + @status.mentions.map(&:account_id)).uniq
    !Follow.exists?(account_id: account_ids, target_account_id: @status.account.id)
  end

  def report_if_needed!
    return if system_reports.unresolved.exists?(target_account: @status.account)

    system_reports.create!(
      category: :spam,
      comment: 'Account automatically reported for posting a banned URL',
      target_account: @status.account
    )
  end

  def system_reports
    Account.representative.reports
  end

  def status_text
    @status_text ||= @status.text.unicode_normalize(:nfkc).downcase
  end
end
