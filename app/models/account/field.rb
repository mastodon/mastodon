# frozen_string_literal: true

class Account::Field < ActiveModelSerializers::Model
  MAX_CHARACTERS_LOCAL  = 255
  MAX_CHARACTERS_COMPAT = 2_047
  ACCEPTED_SCHEMES      = %w(https).freeze

  attributes :name, :value, :verified_at, :account

  def initialize(account, attributes)
    # Keeping this as reference allows us to update the field on the account
    # from methods in this class, so that changes can be saved.
    @original_field = attributes
    @account        = account

    super(
      name:        sanitize(attributes['name']),
      value:       sanitize(attributes['value']),
      verified_at: attributes['verified_at']&.to_datetime,
    )
  end

  def verified?
    verified_at.present?
  end

  def value_for_verification
    @value_for_verification ||= begin
      if account.local?
        value
      else
        extract_url_from_html
      end
    end
  end

  def verifiable?
    return false if value_for_verification.blank?

    # This is slower than checking through a regular expression, but we
    # need to confirm that it's not an IDN domain.

    parsed_url = Addressable::URI.parse(value_for_verification)

    ACCEPTED_SCHEMES.include?(parsed_url.scheme) &&
      parsed_url.user.nil? &&
      parsed_url.password.nil? &&
      parsed_url.host.present? &&
      parsed_url.normalized_host == parsed_url.host
  rescue Addressable::URI::InvalidURIError, IDN::Idna::IdnaError
    false
  end

  def requires_verification?
    !verified? && verifiable?
  end

  def mark_verified!
    @original_field['verified_at'] = self.verified_at = Time.now.utc
  end

  def to_h
    { name: name, value: value, verified_at: verified_at }
  end

  private

  def sanitize(str)
    str.strip[0, character_limit]
  end

  def character_limit
    account.local? ? MAX_CHARACTERS_LOCAL : MAX_CHARACTERS_COMPAT
  end

  def extract_url_from_html
    doc = Nokogiri::HTML(value).at_xpath('//body')

    return if doc.nil?
    return if doc.children.size > 1

    element = doc.children.first

    return if element.name != 'a' || element['href'] != element.text

    element['href']
  end
end
