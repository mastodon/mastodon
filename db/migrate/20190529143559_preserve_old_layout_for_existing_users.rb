# frozen_string_literal: true

class PreserveOldLayoutForExistingUsers < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    # Assume that currently active users are already using the layout that they
    # want to use, therefore ensure that it is saved explicitly and not based
    # on the to-be-changed default

    User.where(User.arel_table[:current_sign_in_at].gteq(1.month.ago)).find_each do |user|
      next if Setting.unscoped.exists?(thing_type: 'User', thing_id: user.id, var: 'advanced_layout')

      user.settings.advanced_layout = true
    end
  end

  def down; end
end
