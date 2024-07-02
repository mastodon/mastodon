# frozen_string_literal: true

class DisposableEmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    return unless disposable_email?(value)

    record.errors.add(
      attribute,
      (options[:message] || I18n.t('disposable_email_validator.invalid'))
    )
  end

  private

  def disposable_email?(email)
    email_address = begin
      Mail::Address.new(email.downcase)
    rescue
      nil
    end

    return false unless email_address

    disposable_email_domains.include?(email_address.domain)
  end

  def disposable_email_domains
    file_path = Rails.root.join('data', 'disposable_email_domains.txt')
    return [] unless File.exist? file_path

    data = File.read(file_path)
    JSON.parse(data)
  end
end
