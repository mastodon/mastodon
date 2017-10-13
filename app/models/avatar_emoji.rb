# frozen_string_literal: true

class AvatarEmoji
  include ActiveModel::Serialization

  attr_reader :account

  Image = Struct.new(:source) do
    def url(type = :original)
      type = :original unless source.content_type == 'image/gif'
      source.url(type)
    end
  end

  def initialize(account)
    @account = account
  end

  def shortcode
    "@#{account.acct}"
  end

  def image
    @image ||= Image.new(account.avatar)
  end

  def attributes
    {}
  end

  def inspect
    "#<AvatarEmoji shortcode: #{shortcode}, account_id: #{account.id}>"
  end

  SHORTCODE_RE_FRAGMENT = /@(([a-z0-9_]+)(?:@[a-z0-9\.\-]+[a-z0-9]+)?)/i

  SCAN_RE = /:#{SHORTCODE_RE_FRAGMENT}:/x

  class << self
    def from_text(text, domain = nil)
      return [] if text.blank?

      shortcodes = text.scan(SCAN_RE).map(&:first).uniq

      return [] if shortcodes.empty?

      accounts = shortcodes.reduce(Account.where('1 = 0')) do |query, shortcode|
        username, host = shortcode.split('@')
        query.or(Account.where(username: username, domain: host || domain))
      end

      accounts.map { |account| new(account) }
    end
  end
end
