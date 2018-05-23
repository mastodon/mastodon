require 'chewy/type/adapter/base'

module Chewy
  class Type
    module Adapter
      class Sequel < Orm
        attr_reader :default_scope
        alias_method :default_dataset, :default_scope

        def self.accepts?(target)
          defined?(::Sequel::Model) && (
            target.is_a?(Class) && target < ::Sequel::Model ||
            target.is_a?(::Sequel::Dataset))
        end

      private

        def cleanup_default_scope!
          Chewy.logger.warn('Default type scope order, limit and offset are ignored and will be nullified') if Chewy.logger && @default_scope != @default_scope.unordered.unlimited

          @default_scope = @default_scope.unordered.unlimited
        end

        def import_scope(scope, options)
          pluck_in_batches(scope, options.slice(:batch_size)).inject(true) do |result, ids|
            result & yield(grouped_objects(default_scope_where_ids_in(ids).all))
          end
        end

        def primary_key
          target.primary_key
        end

        def full_column_name(column)
          ::Sequel.qualify(target.table_name, column)
        end

        def all_scope
          target.dataset
        end

        def target_columns
          @target_columns ||= target.columns.to_set
        end

        def pluck(scope, fields: [])
          fields = fields.map(&:to_sym).unshift(primary_key).map do |column|
            target_columns.include?(column) ? full_column_name(column) : column
          end
          scope.distinct.select_map(fields.one? ? fields.first : fields)
        end

        def pluck_in_batches(scope, fields: [], batch_size: nil, **options)
          return enum_for(:pluck_in_batches, scope, fields: fields, batch_size: batch_size, **options) unless block_given?

          scope = scope.unordered.order(full_column_name(primary_key).asc).limit(batch_size)

          ids = pluck(scope, fields: fields)
          count = 0

          while ids.present?
            yield ids
            break if ids.size < batch_size
            last_id = ids.last.is_a?(Array) ? ids.last.first : ids.last
            ids = pluck(scope.where { |_o| full_column_name(primary_key) > last_id }, fields: fields)
          end

          count
        end

        def scope_where_ids_in(scope, ids)
          scope.where(full_column_name(primary_key) => Array.wrap(ids))
        end

        def model_of_relation(relation)
          relation.model
        end

        def relation_class
          ::Sequel::Dataset
        end

        def object_class
          ::Sequel::Model
        end

        def load_scope_objects(*args)
          super.all
        end
      end
    end
  end
end
