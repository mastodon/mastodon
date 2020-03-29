# frozen_string_literal: true

class ActivityPub::Serializer < ActiveModel::Serializer
  with_options instance_writer: false, instance_reader: true do |serializer|
    serializer.class_attribute :_named_contexts
    serializer.class_attribute :_context_extensions

    self._named_contexts     ||= {}
    self._context_extensions ||= {}
  end

  def self.inherited(base)
    super

    base._named_contexts     = _named_contexts.dup
    base._context_extensions = _context_extensions.dup
  end

  def self.context(*named_contexts)
    named_contexts.each do |context|
      _named_contexts[context] = true
    end
  end

  def self.context_extensions(*extension_names)
    extension_names.each do |extension_name|
      _context_extensions[extension_name] = true
    end
  end

  def serializable_hash(adapter_options = nil, options = {}, adapter_instance = self.class.serialization_adapter_instance)
    unless adapter_options&.fetch(:named_contexts, nil).nil?
      adapter_options[:named_contexts].merge!(_named_contexts)
      adapter_options[:context_extensions].merge!(_context_extensions)
    end
    super(adapter_options, options, adapter_instance)
  end
end
