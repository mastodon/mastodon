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

  def local_preflight_check!(status)
    return unless considered_spam?(status)

    report_if_needed!(status.account)

    raise SilentlyDrop, status
  end

  private

  def considered_spam?(status)
    (all_time_suspicious?(status) || recent_suspicious?(status)) && suspicious_reply_or_mention?(status)
  end

  def all_time_suspicious?(status)
    all_time_spammy_texts.any? { |spammy_text| status.text.include?(spammy_text) }
  end

  def recent_suspicious?(status)
    status.account.created_at >= ACCOUNT_AGE_EXEMPTION.ago && spammy_texts.any? { |spammy_text| status.text.include?(spammy_text) }
  end

  def spammy_texts
    redis.smembers('antispam:spammy_texts')
  end

  def all_time_spammy_texts
    redis.smembers('antispam:all_time_spammy_texts')
  end

  def suspicious_reply_or_mention?(status)
    parent = status.thread
    return true if parent.present? && !Follow.exists?(account_id: parent.account_id, target_account: status.account_id)

    account_ids = status.mentions.map(&:account_id).uniq
    !Follow.exists?(account_id: account_ids, target_account_id: status.account.id)
  end

  def report_if_needed!(account)
    return if Report.unresolved.exists?(account: Account.representative, target_account: account)

    Report.create!(account: Account.representative, target_account: account, category: :spam, comment: 'Account automatically reported for posting a banned URL')
  end
end
