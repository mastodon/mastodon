# frozen_string_literal: true

class Admin::SystemCheck::DatabaseSchemaCheck < Admin::SystemCheck::BaseCheck
  def skip?
    !current_user.can?(:view_devops)
  end

  def pass?
    !ActiveRecord::Base.connection_pool.migration_context.needs_migration?
  end

  def message
    Admin::SystemCheck::Message.new(:database_schema_check)
  end
end
