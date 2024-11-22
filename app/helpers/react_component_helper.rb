# frozen_string_literal: true

module ReactComponentHelper
  def react_component(name, props = {}, &block)
    data = { component: name.to_s.camelcase, props: Oj.dump(props) }
    if block.nil?
      div_tag_with_data(data)
    else
      content_tag(:div, data: data, &block)
    end
  end

  def react_admin_component(name, props = {})
    data = { 'admin-component': name.to_s.camelcase, props: Oj.dump(props) }
    div_tag_with_data(data)
  end

  def serialized_media_attachments(media_attachments)
    media_attachments.map { |attachment| serialized_attachment(attachment) }
  end

  private

  def div_tag_with_data(data)
    content_tag(:div, nil, data: data)
  end

  def serialized_attachment(attachment)
    ActiveModelSerializers::SerializableResource.new(
      attachment,
      serializer: REST::MediaAttachmentSerializer
    ).as_json
  end
end
