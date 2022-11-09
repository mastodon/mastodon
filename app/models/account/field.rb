# frozen_string_literal: true

class Account::Field < ActiveModelSerializers::Model
  MAX_CHARACTERS_LOCAL  = 255
  MAX_CHARACTERS_COMPAT = 2_047

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
    value_for_verification.present? && /\A#{FetchLinkCardService::URL_PATTERN}\z/.match?(value_for_verification)
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

    return if doc.children.size > 1

    element = doc.children.first

    return if element.name != 'a' || element['href'] != element.text

    element['href']
  end
end
