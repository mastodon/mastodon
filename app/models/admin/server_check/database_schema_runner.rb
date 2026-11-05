# frozen_string_literal: true

class Admin::ServerCheck::DatabaseSchemaRunner
  include Admin::ServerCheck::Runner

  def authorized?(user)
    user.can?(:view_devops)
  end

  def run
    if ActiveRecord::Base.connection_pool.migration_context.needs_migration?
      pending
    else
      ok
    end
  end
end
