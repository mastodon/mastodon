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
#  recorded_changes :text             default(""), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Admin::ActionLog < ApplicationRecord
  serialize :recorded_changes

  belongs_to :account
  belongs_to :target, polymorphic: true, optional: true

  default_scope -> { order('id desc') }

  def action
    super.to_sym
  end

  before_validation :set_changes

  private

  def set_changes
    case action
    when :destroy, :create
      self.recorded_changes = target.attributes
    when :update, :promote, :demote
      self.recorded_changes = target.previous_changes
    when :change_email
      self.recorded_changes = ActiveSupport::HashWithIndifferentAccess.new(
        email: [target.email, nil],
        unconfirmed_email: [nil, target.unconfirmed_email]
      )
    end
  end
end
