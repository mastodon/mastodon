# frozen_string_literal: true

class REST::ExtendedDescriptionSerializer < ActiveModel::Serializer
  attributes :updated_at, :content

  def updated_at
    object.updated_at&.iso8601
  end

  def content
    if object.text.present?
      markdown.render(object.text)
    else
      ''
    end
  end

  private

  def markdown
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  end
end
