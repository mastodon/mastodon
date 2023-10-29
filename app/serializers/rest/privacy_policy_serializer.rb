# frozen_string_literal: true

class REST::PrivacyPolicySerializer < ActiveModel::Serializer
  attributes :updated_at, :content

  def updated_at
    object.updated_at.iso8601
  end

  def content
    markdown.render(format(object.text, domain: Rails.configuration.x.local_domain))
  end

  private

  def markdown
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, escape_html: true, no_images: true)
  end
end
