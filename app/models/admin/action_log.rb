# frozen_string_literal: true
# == Schema Information
#
# Table name: admin_action_logs
#
#  id               :integer          not null, primary key
#  account_id       :integer
#  action           :string           default(""), not null
#  target_type      :string
#  target_id        :integer
#  recorded_changes :text             default(""), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Admin::ActionLog < ApplicationRecord
  serialize :recorded_changes

  belongs_to :account
  belongs_to :target, polymorphic: true

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
    end
  end
end
