require 'fog/core/collection'

module Fog
  module OpenStack
    class Collection < Fog::Collection
      # It's important to store the whole response, it contains e.g. important info about whether there is another
      # page of data.
      attr_accessor :response

      def load_response(response, index = nil)
        # Delete it index if it's there, so we don't store response with data twice, but we store only metadata
        objects = index ? response.body.delete(index) : response.body

        clear && objects.each { |object| self << new(object) }
        self.response = response
        self
      end

      ##################################################################################################################
      # Abstract base class methods, please keep the consistent naming in all subclasses of the Collection class

      # Returns detailed list of records
      def all(options = {})
        raise Fog::OpenStack::Errors::InterfaceNotImplemented.new('Method :all is not implemented')
      end

      # Returns non detailed list of records, usually just subset of attributes, which makes this call more effective.
      # Not all openstack services support non detailed list, so it delegates to :all by default.
      def summary(options = {})
        all(options)
      end

      # Gets record given record's UUID
      def get(uuid)
        raise Fog::OpenStack::Errors::InterfaceNotImplemented.new('Method :get is not implemented')
      end

      def find_by_id(uuid)
        get(uuid)
      end

      # Destroys record given record's UUID
      def destroy(uuid)
        raise Fog::OpenStack::Errors::InterfaceNotImplemented.new('Method :destroy is not implemented')
      end
    end
  end
end
