# frozen_string_literal: true

class UserSettings::Setting
  attr_reader :name, :namespace, :in

  def initialize(name, options = {})
    @name          = name.to_sym
    @default_value = options[:default]
    @namespace     = options[:namespace]
    @in            = options[:in]
  end

  def default_value
    if @default_value.respond_to?(:call)
      @default_value.call
    else
      @default_value
    end
  end

  def type
    if @default_value.is_a?(TrueClass) || @default_value.is_a?(FalseClass)
      ActiveModel::Type::Boolean.new
    else
      ActiveModel::Type::String.new
    end
  end

  def type_cast(value)
    if type.respond_to?(:cast)
      type.cast(value)
    else
      value
    end
  end

  def to_a
    [key, default_value]
  end

  def key
    if namespace
      "#{namespace}.#{name}".to_sym
    else
      name
    end
  end
end
