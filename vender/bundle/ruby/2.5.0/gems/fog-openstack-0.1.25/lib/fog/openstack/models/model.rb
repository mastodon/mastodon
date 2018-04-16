require 'fog/core/model'

module Fog
  module OpenStack
    class Model < Fog::Model
      # In some cases it's handy to be able to store the project for the record, e.g. swift doesn't contain project info
      # in the result, so we can track it in this attribute based on what project was used in the request
      attr_accessor :project

      ##################################################################################################################
      # Abstract base class methods, please keep the consistent naming in all subclasses of the Model class

      # Initialize a record
      def initialize(attributes)
        # Old 'connection' is renamed as service and should be used instead
        prepare_service_value(attributes)
        super
      end

      # Saves a record, call create or update based on identity, which marks if object was already created
      def save
        identity ? update : create
      end

      # Updates a record
      def update
        # uncomment when exception is defined in another PR
        # raise Fog::OpenStack::Errors::InterfaceNotImplemented.new('Method :get is not implemented')
      end

      # Creates a record
      def create
        # uncomment when exception is defined in another PR
        # raise Fog::OpenStack::Errors::InterfaceNotImplemented.new('Method :get is not implemented')
      end

      # Destroys a record
      def destroy
        # uncomment when exception is defined in another PR
        # raise Fog::OpenStack::Errors::InterfaceNotImplemented.new('Method :get is not implemented')
      end
    end
  end
end
