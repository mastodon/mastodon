# frozen_string_literal: true

require 'resolv'

class EmailMxValidator < ActiveModel::Validator
  def validate(user)
    return if Rails.env.test? || Rails.env.development?
    user.errors.add(:email, I18n.t('users.invalid_email')) if invalid_mx?(user.email)
  end

  private

  def invalid_mx?(value)
    _, domain = value.split('@', 2)

    return true if domain.nil?

    records = Resolv::DNS.new.getresources(domain, Resolv::DNS::Resource::IN::MX).to_a.map { |e| e.exchange.to_s }
    records = Resolv::DNS.new.getresources(domain, Resolv::DNS::Resource::IN::A).to_a.map { |e| e.address.to_s } if records.empty?

    records.empty? || on_blacklist?(records)
  end

  def on_blacklist?(values)
    EmailDomainBlock.where(domain: values).any?
  end
end
