require 'mongoid'

module Mongoid
  module Document
    module ClassMethods
      include OrmAdapter::ToAdapter
    end

    class OrmAdapter < ::OrmAdapter::Base
      # get a list of column names for a given class
      def column_names
        klass.fields.keys
      end

      # @see OrmAdapter::Base#get!
      def get!(id)
        klass.find(wrap_key(id))
      end

      # @see OrmAdapter::Base#get
      def get(id)
        klass.where(:_id => wrap_key(id)).first
      end

      # @see OrmAdapter::Base#find_first
      def find_first(options = {})
        conditions, order = extract_conditions!(options)
        klass.limit(1).where(conditions_to_fields(conditions)).order_by(order).first
      end

      # @see OrmAdapter::Base#find_all
      def find_all(options = {})
        conditions, order, limit, offset = extract_conditions!(options)
        klass.where(conditions_to_fields(conditions)).order_by(order).limit(limit).offset(offset)
      end

      # @see OrmAdapter::Base#create!
      def create!(attributes = {})
        klass.create!(attributes)
      end

      # @see OrmAdapter::Base#destroy
      def destroy(object)
        object.destroy if valid_object?(object)
      end

    protected

      # converts and documents to ids
      def conditions_to_fields(conditions)
        conditions.inject({}) do |fields, (key, value)|
          if value.is_a?(Mongoid::Document) && klass.fields.keys.include?("#{key}_id")
            fields.merge("#{key}_id" => value.id)
          elsif key.to_s == 'id'
            fields.merge('_id' => value)
          else
            fields.merge(key => value)
          end
        end
      end
    end
  end
end
