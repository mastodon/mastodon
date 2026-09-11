# frozen_string_literal: true

class REST::PartialAccountSerializer < REST::AccountSerializer
  # This is a hack to reset ActiveModel::Serializer internals and only expose the attributes
  # we care about.
  self._attributes_data = {}
  self._reflections = []
  self._links = []

  attributes :id, :acct, :locked, :bot, :url, :avatar, :avatar_static, :avatar_description
end
