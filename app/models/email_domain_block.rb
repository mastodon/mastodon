# frozen_string_literal: true
# == Schema Information
#
# Table name: email_domain_blocks
#
#  id         :integer          not null, primary key
#  domain     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class EmailDomainBlock < ApplicationRecord
  def self.block?(email)
    domain = email.gsub(/.+@([^.]+)/, '\1')
    where(domain: domain).exists?
  end
end
