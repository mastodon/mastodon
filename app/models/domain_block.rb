# frozen_string_literal: true
# == Schema Information
#
# Table name: domain_blocks
#
#  id           :integer          not null, primary key
#  domain       :string           default(""), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  severity     :integer          default("silence")
#  reject_media :boolean          default(FALSE), not null
#  sensitive    :boolean          default(FALSE), not null
#

class DomainBlock < ApplicationRecord
  enum severity: [:silence, :suspend, :noop]

  attr_accessor :retroactive

  validates :domain, presence: true, uniqueness: true

  has_many :accounts, foreign_key: :domain, primary_key: :domain
  delegate :count, to: :accounts, prefix: true

  def self.blocked?(domain)
    where(domain: domain, severity: :suspend).exists?
  end

  before_validation :normalize_domain

  def image_severity
    return :reject_media if reject_media?
    return :sensitive if sensitive?

    nil
  end

  def image_severity=(type)
    case type.to_sym
    when :reject_media
      self.reject_media = true
      self.sensitive    = false
    when :sensitive
      self.reject_media = false
      self.sensitive    = true
    else
      self.reject_media = false
      self.sensitive    = false
    end
  end

  private

  def normalize_domain
    self.domain = TagManager.instance.normalize_domain(domain)
  end
end
