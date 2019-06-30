# frozen_string_literal: true

class SpamCheck
  include Redisable
  include ActionView::Helpers::TextHelper

  LEVENSHTEIN_THRESHOLD = 10

  def initialize(status)
    @account = status.account
    @status  = status
  end

  def skip?
    already_flagged? || no_unsolicited_mentions?
  end

  def spam?
    other_digests = redis.zrange("spam_check:#{@account.id}", '0', '-1')
    other_digests.any? { |other_digest| levenshtein(digest, other_digest) < LEVENSHTEIN_THRESHOLD }
  end

  def flag!
    auto_silence_account!
    auto_report_status!
  end

  def remember!
    redis.zadd("spam_check:#{@account.id}", @status.id, digest)
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
    @digest ||= Nilsimsa.new(hashable_text).hexdigest
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
    ReportService.new.call(Account.representative, @account, status_ids: [@status.id]) unless @account.targeted_reports.unresolved.exists?
  end

  def already_flagged?
    @account.silenced?
  end

  def no_unsolicited_mentions?
    @status.mentions.all? { |mention| mention.silent? || !mention.account.local? || mention.account.following?(@account) }
  end

  def levenshtein(first, second)
    m = first.length
    n = second.length

    return m if n.zero?
    return n if m.zero?

    d = Array.new(m + 1) { Array.new(n + 1) }

    0.upto(m) { |i| d[i][0] = i }
    0.upto(n) { |j| d[0][j] = j }

    1.upto(n) do |j|
      1.upto(m) do |i|
        d[i][j] = first[i - 1] == second[j - 1] ? d[i - 1][j - 1] : [d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + 1].min
      end
    end

    d[m][n]
  end
end
