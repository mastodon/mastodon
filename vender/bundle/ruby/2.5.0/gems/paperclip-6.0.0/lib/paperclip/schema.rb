require 'active_support/deprecation'

module Paperclip
  # Provides helper methods that can be used in migrations.
  module Schema
    COLUMNS = {:file_name    => :string,
               :content_type => :string,
               :file_size    => :integer,
               :updated_at   => :datetime}

    def self.included(base)
      ActiveRecord::ConnectionAdapters::Table.send :include, TableDefinition
      ActiveRecord::ConnectionAdapters::TableDefinition.send :include, TableDefinition
      ActiveRecord::ConnectionAdapters::AbstractAdapter.send :include, Statements
      ActiveRecord::Migration::CommandRecorder.send :include, CommandRecorder
    end

    module Statements
      def add_attachment(table_name, *attachment_names)
        raise ArgumentError, "Please specify attachment name in your add_attachment call in your migration." if attachment_names.empty?

        options = attachment_names.extract_options!

        attachment_names.each do |attachment_name|
          COLUMNS.each_pair do |column_name, column_type|
            column_options = options.merge(options[column_name.to_sym] || {})
            add_column(table_name, "#{attachment_name}_#{column_name}", column_type, column_options)
          end
        end
      end

      def remove_attachment(table_name, *attachment_names)
        raise ArgumentError, "Please specify attachment name in your remove_attachment call in your migration." if attachment_names.empty?

        attachment_names.each do |attachment_name|
          COLUMNS.keys.each do |column_name|
            remove_column(table_name, "#{attachment_name}_#{column_name}")
          end
        end
      end

      def drop_attached_file(*args)
        ActiveSupport::Deprecation.warn "Method `drop_attached_file` in the migration has been deprecated and will be replaced by `remove_attachment`."
        remove_attachment(*args)
      end
    end

    module TableDefinition
      def attachment(*attachment_names)
        options = attachment_names.extract_options!
        attachment_names.each do |attachment_name|
          COLUMNS.each_pair do |column_name, column_type|
            column_options = options.merge(options[column_name.to_sym] || {})
            column("#{attachment_name}_#{column_name}", column_type, column_options)
          end
        end
      end

      def has_attached_file(*attachment_names)
        ActiveSupport::Deprecation.warn "Method `t.has_attached_file` in the migration has been deprecated and will be replaced by `t.attachment`."
        attachment(*attachment_names)
      end
    end

    module CommandRecorder
      def add_attachment(*args)
        record(:add_attachment, args)
      end

      private

      def invert_add_attachment(args)
        [:remove_attachment, args]
      end
    end
  end
end
