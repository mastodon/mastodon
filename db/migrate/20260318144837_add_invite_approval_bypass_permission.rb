# frozen_string_literal: true

class AddInviteApprovalBypassPermission < ActiveRecord::Migration[8.1]
  class UserRole < ApplicationRecord; end

  def up
    UserRole.where('permissions & (1 << 16) = 1 << 16').update_all('permissions = permissions | (1 << 21)')
  end

  def down; end
end
