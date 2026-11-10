# frozen_string_literal: true

class SEO::ProfilePageSerializer < ActiveModel::Serializer
  attributes :context, :type, :date_published, :date_modified

  has_one :main_entity, serializer: SEO::PersonSerializer

  def context
    'https://schema.org'
  end

  def type
    'ProfilePage'
  end

  def date_published
    object.created_at.iso8601
  end

  def date_modified
    object.updated_at.iso8601
  end

  def main_entity
    object
  end
end
