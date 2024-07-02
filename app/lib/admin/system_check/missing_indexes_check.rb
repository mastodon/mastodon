# frozen_string_literal: true

class Admin::SystemCheck::MissingIndexesCheck < Admin::SystemCheck::BaseCheck
  def skip?
    !current_user.can?(:view_devops)
  end

  def pass?
    missing_indexes.none?
  end

  def message
    Admin::SystemCheck::Message.new(:missing_indexes_check, missing_indexes.join(', '))
  end

  private

  def missing_indexes
    @missing_indexes ||= begin
      expected_indexes_by_table.flat_map do |table, indexes|
        expected_indexes = indexes.map(&:name)
        expected_indexes - existing_indexes_for(table)
      end
    end
  end

  def expected_indexes_by_table
    schema_rb = Rails.root.join('db', 'schema.rb').read
    schema_parser = Admin::Db::SchemaParser.new(schema_rb)
    schema_parser.indexes_by_table
  end

  def existing_indexes_for(table)
    ActiveRecord::Base.connection.indexes(table).map(&:name)
  end
end
