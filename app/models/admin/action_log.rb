# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_action_logs
#
#  id               :bigint(8)        not null, primary key
#  account_id       :bigint(8)
#  action           :string           default(""), not null
#  target_type      :string
#  target_id        :bigint(8)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  human_identifier :string
#  route_param      :string
#  permalink        :string
#

class Admin::ActionLog < ApplicationRecord
  self.ignored_columns = %w(
    recorded_changes
  )

  belongs_to :account
  belongs_to :target, polymorphic: true, optional: true

  default_scope -> { order('id desc') }

  before_validation :set_human_identifier
  before_validation :set_route_param
  before_validation :set_permalink

  def action
    super.to_sym
  end

  private

  def set_human_identifier
    self.human_identifier = target.to_log_human_identifier if target.respond_to?(:to_log_human_identifier)
  end

  def set_route_param
    self.route_param = target.to_log_route_param if target.respond_to?(:to_log_route_param)
  end

  def set_permalink
    self.permalink = target.to_log_permalink if target.respond_to?(:to_log_permalink)
  end
end
