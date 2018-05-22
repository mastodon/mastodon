# frozen_string_literal: true
require 'resolv'
class EmailMXValidator < ActiveModel::Validator
  def validate(user)
    domain = user.email.split('@', 2).last
    mxs = Resolv::DNS.new.getresources(domain, Resolv::DNS::Resource::IN::MX).to_a.map { |e| e.exchange.to_s }

    user.errors.add(:email, "Email address does not appear to be valid. Please check that you've typed it correctly.") if mxs.empty? || blocked_mx?(mxs)
  end

  private

  def blocked_mx?(mxs)
    EmailDomainBlock.where('domain IN (?)', mxs).exists?
  end
end
