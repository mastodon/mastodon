# frozen_string_literal: true

class SpamCheck
  include Redisable
  include ActionView::Helpers::TextHelper

  NILSIMSA_COMPARE_THRESHOLD = 54
  NILSIMSA_MIN_SIZE = 10

  def initialize(status)
    @account = status.account
    @status  = status
  end

  def skip?
    already_flagged? || trusted? || no_unsolicited_mentions? || solicited_reply?
  end

  def spam?
    if nilsimsa?
      other_digests = redis.zrange("spam_check:#{@account.id}", '0', '-1')
      other_digests.select { |other_digest| other_digest.start_with?('nilsimsa') }.any? { |other_digest| nilsimsa_compare_value(digest, other_digest.split(':').last) >= NILSIMSA_COMPARE_THRESHOLD }
    else
      !redis.zrank("spam_check:#{@account.id}", digest_with_algorithm).nil?
    end
  end

  def flag!
    auto_silence_account!
    auto_report_status!
  end

  def remember!
    redis.zadd("spam_check:#{@account.id}", @status.id, digest_with_algorithm)
    redis.zremrangebyrank("spam_check:#{@account.id}", '0', '-10')
  end

  private

  def hashable_text
    return @hashable_text if defined?(@hashable_text)

    @hashable_text = @status.text
    @hashable_text = remove_mentions(@hashable_text)
    @hashable_text = strip_tags(@hashable_text)
    @hashable_text = normalize_unicode(@hashable_text)
    @hashable_text = remove_whitespace(@hashable_text)
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
      ['nilsimsa', digest].join(':')
    else
      ['md5', digest].join(':')
    end
  end

  def remove_mentions(text)
    Nokogiri::HTML.fragment(text).tap do |html|
      mentions = @status.mentions.map { |mention| TagManager.instance.url_for(mention.account) }

      html.traverse do |element|
        element.unlink if element.name == 'a' && mentions.include?(element['href'])
      end
    end.to_s
  end

  def normalize_unicode(text)
    text.unicode_normalize(:nfkc).downcase
  end

  def remove_whitespace(text)
    text.gsub(/\s+/, '')
  end

  def auto_silence_account!
    @account.silence!
  end

  def auto_report_status!
    ReportService.new.call(Account.representative, @account, status_ids: @status.distributable? ? [@status.id] : nil, comment: I18n.t('spam_check.spam_detected_and_silenced')) unless @account.targeted_reports.unresolved.exists?
  end

  def already_flagged?
    @account.silenced?
  end

  def trusted?
    @account.trust_level > Account::TRUST_LEVELS[:untrusted]
  end

  def no_unsolicited_mentions?
    @status.mentions.all? { |mention| mention.silent? || !mention.account.local? || mention.account.following?(@account) }
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
end
