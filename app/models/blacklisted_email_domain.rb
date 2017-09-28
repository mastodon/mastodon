# frozen_string_literal: true
# == Schema Information
#
# Table name: blacklisted_email_domains
#
#  id         :integer          not null, primary key
#  domain     :string           not null
#  note       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BlacklistedEmailDomain < ApplicationRecord
  def self.block?(email)
    domain = email.gsub(/.+@([^.]+)/, '\1')
    where(domain: domain).exists?
  end
end
