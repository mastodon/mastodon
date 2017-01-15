# frozen_string_literal: true

module Settings
  class ScopedSettings < ::Setting
    def self.for_thing(object)
      @object = object
      self
    end

    def self.thing_scoped
      unscoped.where(thing_type: @object.class.base_class.to_s, thing_id: @object.id)
    end
  end
end
