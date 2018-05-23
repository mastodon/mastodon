require 'active_record'

module OrmAdapter
  class ActiveRecord < Base
    # Return list of column/property names
    def column_names
      klass.column_names
    end

    # @see OrmAdapter::Base#get!
    def get!(id)
      klass.find(wrap_key(id))
    end

    # @see OrmAdapter::Base#get
    def get(id)
      klass.where(klass.primary_key => wrap_key(id)).first
    end

    # @see OrmAdapter::Base#find_first
    def find_first(options = {})
      construct_relation(klass, options).first
    end

    # @see OrmAdapter::Base#find_all
    def find_all(options = {})
      construct_relation(klass, options)
    end

    # @see OrmAdapter::Base#create!
    def create!(attributes = {})
      klass.create!(attributes)
    end

    # @see OrmAdapter::Base#destroy
    def destroy(object)
      object.destroy && true if valid_object?(object)
    end

  protected
    def construct_relation(relation, options)
      conditions, order, limit, offset = extract_conditions!(options)

      relation = relation.where(conditions_to_fields(conditions))
      relation = relation.order(order_clause(order)) if order.any?
      relation = relation.limit(limit) if limit
      relation = relation.offset(offset) if offset

      relation
    end

    # Introspects the klass to convert and objects in conditions into foreign key and type fields
    def conditions_to_fields(conditions)
      fields = {}
      conditions.each do |key, value|
        if value.is_a?(::ActiveRecord::Base) && (assoc = klass.reflect_on_association(key.to_sym)) && assoc.belongs_to?

          if ::ActiveRecord::VERSION::STRING < "3.1"
            fields[assoc.primary_key_name] = value.send(value.class.primary_key)
            fields[assoc.options[:foreign_type]] = value.class.base_class.name.to_s if assoc.options[:polymorphic]
          else # >= 3.1
            fields[assoc.foreign_key] = value.send(value.class.primary_key)
            fields[assoc.foreign_type] = value.class.base_class.name.to_s if assoc.options[:polymorphic]
          end

        else
          fields[key] = value
        end
      end
      fields
    end

    def order_clause(order)
      order.map {|pair| "#{pair[0]} #{pair[1]}"}.join(",")
    end
  end
end

ActiveSupport.on_load(:active_record) do
  extend ::OrmAdapter::ToAdapter
  self::OrmAdapter = ::OrmAdapter::ActiveRecord
end
