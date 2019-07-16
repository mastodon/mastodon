# frozen_string_literal: true

class SpamCheck
  include Redisable
  include ActionView::Helpers::TextHelper

  NILSIMSA_COMPARE_THRESHOLD = 95
  NILSIMSA_MIN_SIZE          = 10
  EXPIRE_SET_AFTER           = 1.week.seconds

  def initialize(status)
    @account = status.account
    @status  = status
  end

  def skip?
    disabled? || already_flagged? || trusted? || no_unsolicited_mentions? || solicited_reply?
  end

  def spam?
    if insufficient_data?
      false
    elsif nilsimsa?
      any_other_digest?('nilsimsa') { |_, other_digest| nilsimsa_compare_value(digest, other_digest) >= NILSIMSA_COMPARE_THRESHOLD }
    else
      any_other_digest?('md5') { |_, other_digest| other_digest == digest }
    end
  end

  def flag!
    auto_silence_account!
    auto_report_status!
  end

  def remember!
    # The scores in sorted sets don't actually have enough bits to hold an exact
    # value of our snowflake IDs, so we use it only for its ordering property. To
    # get the correct status ID back, we have to save it in the string value

    redis.zadd(redis_key, @status.id, digest_with_algorithm)
    redis.zremrangebyrank(redis_key, '0', '-10')
    redis.expire(redis_key, EXPIRE_SET_AFTER)
  end

  def reset!
    redis.del(redis_key)
  end

  def hashable_text
    return @hashable_text if defined?(@hashable_text)

    @hashable_text = @status.text
    @hashable_text = remove_mentions(@hashable_text)
    @hashable_text = strip_tags(@hashable_text) unless @status.local?
    @hashable_text = normalize_unicode(@status.spoiler_text + ' ' + @hashable_text)
    @hashable_text = remove_whitespace(@hashable_text)
  end

  def insufficient_data?
    hashable_text.blank?
  end

  def digest
    @digest ||= begin
      if nilsimsa?
        Nilsimsa.new(hashable_text).hexdigest
      else
        Digest::MD5.hexdigest(hashable_text)
      end
    end
  end

  def digest_with_algorithm
    if nilsimsa?
      ['nilsimsa', digest, @status.id].join(':')
    else
      ['md5', digest, @status.id].join(':')
    end
  end

  private

  def disabled?
    !Setting.spam_check_enabled
  end

  def remove_mentions(text)
    return text.gsub(Account::MENTION_RE, '') if @status.local?

    Nokogiri::HTML.fragment(text).tap do |html|
      mentions = @status.mentions.map { |mention| ActivityPub::TagManager.instance.url_for(mention.account) }

      html.traverse do |element|
        element.unlink if element.name == 'a' && mentions.include?(element['href'])
      end
    end.to_s
  end

  def normalize_unicode(text)
    text.unicode_normalize(:nfkc).downcase
  end

  def remove_whitespace(text)
    text.gsub(/\s+/, ' ').strip
  end

  def auto_silence_account!
    @account.silence!
  end

  def auto_report_status!
    status_ids = Status.where(visibility: %i(public unlisted)).where(id: matching_status_ids).pluck(:id) + [@status.id] if @status.distributable?
    ReportService.new.call(Account.representative, @account, status_ids: status_ids, comment: I18n.t('spam_check.spam_detected_and_silenced'))
  end

  def already_flagged?
    @account.silenced?
  end

  def trusted?
    @account.trust_level > Account::TRUST_LEVELS[:untrusted]
  end

  def no_unsolicited_mentions?
    @status.mentions.all? { |mention| mention.silent? || (!@account.local? && !mention.account.local?) || mention.account.following?(@account) }
  end

  def solicited_reply?
    !@status.thread.nil? && @status.thread.mentions.where(account: @account).exists?
  end

  def nilsimsa_compare_value(first, second)
    first  = [first].pack('H*')
    second = [second].pack('H*')
    bits   = 0

    0.upto(31) do |i|
      bits += Nilsimsa::POPC[255 & (first[i].ord ^ second[i].ord)].ord
    end

    128 - bits # -128 <= Nilsimsa Compare Value <= 128
  end

  def nilsimsa?
    hashable_text.size > NILSIMSA_MIN_SIZE
  end

  def other_digests
    redis.zrange(redis_key, 0, -1)
  end

  def any_other_digest?(filter_algorithm)
    other_digests.any? do |record|
      algorithm, other_digest, status_id = record.split(':')

      next unless algorithm == filter_algorithm

      yield algorithm, other_digest, status_id
    end
  end

  def matching_status_ids
    if nilsimsa?
      other_digests.select { |record| record.start_with?('nilsimsa') && nilsimsa_compare_value(digest, record.split(':')[1]) >= NILSIMSA_COMPARE_THRESHOLD }.map { |record| record.split(':')[2] }.compact
    else
      other_digests.select { |record| record.start_with?('md5') && record.split(':')[1] == digest }.map { |record| record.split(':')[2] }.compact
    end
  end

  def redis_key
    @redis_key ||= "spam_check:#{@account.id}"
  end
end
