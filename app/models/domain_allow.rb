# frozen_string_literal: true
# == Schema Information
#
# Table name: domain_allows
#
#  id         :bigint(8)        not null, primary key
#  domain     :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DomainAllow < ApplicationRecord
  include DomainNormalizable

  def self.allowed?(domain)
    where(domain: domain).exists?
  end
end
