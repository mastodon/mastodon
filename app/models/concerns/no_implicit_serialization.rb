# frozen_string_literal: true

module NoImplicitSerialization
  # Prevent implicit serialization in ActiveModel::Serializer or other code paths.
  # This is a hardening step to avoid accidental leaking of attributes.
  def as_json
    raise NotImplementedError
  end
end
