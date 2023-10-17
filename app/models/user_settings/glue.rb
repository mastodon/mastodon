# frozen_string_literal: true

module UserSettings::Glue
  def to_model
    self
  end

  def to_key
    ''
  end

  def persisted?
    false
  end

  def type_for_attribute(key)
    self.class.definition_for(key)&.type
  end

  def has_attribute?(key) # rubocop:disable Naming/PredicateName
    self.class.definition_for?(key)
  end
end
