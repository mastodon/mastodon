# frozen_string_literal: true
# == Schema Information
#
# Table name: admin_action_logs
#
#  id          :integer          not null, primary key
#  account_id  :integer
#  action      :string           default(""), not null
#  target_type :string
#  target_id   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Admin::ActionLog < ApplicationRecord
  belongs_to :account, required: true
  belongs_to :target, required: true, polymorphic: true

  default_scope -> { order('id desc') }

  def action
    super.to_sym
  end

  def destructive?
    [:silence, :disable, :suspend].include?(action)
  end
end
