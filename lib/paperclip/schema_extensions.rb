# frozen_string_literal: true

# Monkey-patch various Paperclip methods for Ruby 3.0 compatibility

module Paperclip
  module Schema
    module StatementsExtensions
      def add_attachment(table_name, *attachment_names)
        raise ArgumentError, 'Please specify attachment name in your add_attachment call in your migration.' if attachment_names.empty?

        options = attachment_names.extract_options!

        attachment_names.each do |attachment_name|
          COLUMNS.each_pair do |column_name, column_type|
            column_options = options.merge(options[column_name.to_sym] || {})
            add_column(table_name, "#{attachment_name}_#{column_name}", column_type, **column_options)
          end
        end
      end
    end

    module TableDefinitionExtensions
      def attachment(*attachment_names)
        options = attachment_names.extract_options!
        attachment_names.each do |attachment_name|
          COLUMNS.each_pair do |column_name, column_type|
            column_options = options.merge(options[column_name.to_sym] || {})
            column("#{attachment_name}_#{column_name}", column_type, **column_options)
          end
        end
      end
    end
  end
end

Paperclip::Schema::Statements.prepend(Paperclip::Schema::StatementsExtensions)
Paperclip::Schema::TableDefinition.prepend(Paperclip::Schema::TableDefinitionExtensions)
