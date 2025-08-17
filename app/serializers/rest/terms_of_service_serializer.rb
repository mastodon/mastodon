# frozen_string_literal: true

class REST::TermsOfServiceSerializer < ActiveModel::Serializer
  attributes :effective_date, :effective, :content, :succeeded_by

  def effective_date
    (object.effective_date || object.published_at).iso8601
  end

  def effective
    object.effective?
  end

  def succeeded_by
    object.succeeded_by&.effective_date&.iso8601
  end

  def content
    markdown.render(format(object.text, domain: Rails.configuration.x.local_domain))
  end

  private

  def markdown
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, escape_html: true, no_images: true)
  end
end
