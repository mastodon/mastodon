# frozen_string_literal: true

class REST::LanguageSerializer < ActiveModel::Serializer
  attributes :code, :name, :native_name
end
