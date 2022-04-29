# frozen_string_literal: true
# == Schema Information
#
# Table name: instances
#
#  domain         :string           primary key
#  accounts_count :bigint(8)
#

class Instance < ApplicationRecord
  self.primary_key = :domain

  has_many :accounts, foreign_key: :domain, primary_key: :domain

  belongs_to :domain_block, foreign_key: :domain, primary_key: :domain
  belongs_to :domain_allow, foreign_key: :domain, primary_key: :domain

  scope :matches_domain, ->(value) { where(arel_table[:domain].matches("%#{value}%")) }

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: false)
  end

  def readonly?
    true
  end

  def delivery_failure_tracker
    @delivery_failure_tracker ||= DeliveryFailureTracker.new(domain)
  end

  def following_count
    @following_count ||= Follow.where(account: accounts).count
  end

  def followers_count
    @followers_count ||= Follow.where(target_account: accounts).count
  end

  def reports_count
    @reports_count ||= Report.where(target_account: accounts).count
  end

  def blocks_count
    @blocks_count ||= Block.where(target_account: accounts).count
  end

  def public_comment
    domain_block&.public_comment
  end

  def private_comment
    domain_block&.private_comment
  end

  def media_storage
    @media_storage ||= MediaAttachment.where(account: accounts).sum(:file_file_size)
  end

  def to_param
    domain
  end
end
