# frozen_string_literal: true

class Admin::SystemCheck::DatabaseSchemaCheck < Admin::SystemCheck::BaseCheck
  def pass?
    !ActiveRecord::Base.connection.migration_context.needs_migration?
  end

  def message
    Admin::SystemCheck::Message.new(:database_schema_check)
  end
end
