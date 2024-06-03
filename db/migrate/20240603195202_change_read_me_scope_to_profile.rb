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
      applications.each do |application|
        new_scopes = application.scopes.reject { |scope| scope == old_scope }
        new_scopes << new_scope

        application.scopes = new_scopes
        application.save
      end
    end

    Doorkeeper::AccessToken.where("scopes LIKE '%#{old_scope}%'").in_batches do |access_tokens|
      access_tokens.each do |token|
        new_scopes = token.scopes.reject { |scope| scope == old_scope }
        new_scopes << new_scope

        token.scopes = new_scopes
        token.save
      end
    end
  end
end
