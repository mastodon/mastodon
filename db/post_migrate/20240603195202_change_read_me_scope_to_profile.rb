# frozen_string_literal: true

class ChangeReadMeScopeToProfile < ActiveRecord::Migration[7.1]
  def up
    replace_scopes('read:me', 'profile')
  end

  def down
    replace_scopes('profile', 'read:me')
  end

  private

  def replace_scopes(old_scope, new_scope)
    Doorkeeper::Application.where("scopes LIKE '%#{old_scope}%'").in_batches do |applications|
      applications.update_all("scopes = replace(scopes, '#{old_scope}', '#{new_scope}')")
    end

    Doorkeeper::AccessToken.where("scopes LIKE '%#{old_scope}%'").in_batches do |access_tokens|
      access_tokens.update_all("scopes = replace(scopes, '#{old_scope}', '#{new_scope}')")
    end
  end
end
