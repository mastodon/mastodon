# frozen_string_literal: true

class Antispam
  include Redisable

  ACCOUNT_AGE_EXEMPTION = 1.week.freeze

  class SilentlyDrop < StandardError
    attr_reader :status

    def initialize(status)
      super()

      @status = status

      status.created_at = Time.now.utc
      status.id = Mastodon::Snowflake.id_at(status.created_at)
      status.in_reply_to_account_id = status.thread&.account_id

      status.delete # Make sure this is not persisted
    end
  end

  def local_preflight_check!(status)
    return unless spammy_texts.any? { |spammy_text| status.text.include?(spammy_text) }
    return unless status.thread.present? && !status.thread.account.following?(status.account)
    return unless status.account.created_at >= ACCOUNT_AGE_EXEMPTION.ago

    report_if_needed!(status.account)

    raise SilentlyDrop, status
  end

  private

  def spammy_texts
    redis.smembers('antispam:spammy_texts')
  end

  def report_if_needed!(account)
    return if Report.unresolved.exists?(account: Account.representative, target_account: account)

    Report.create!(account: Account.representative, target_account: account, category: :spam, comment: 'Account automatically reported for posting a banned URL')
  end
end
