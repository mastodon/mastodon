# frozen_string_literal: true

module ApplicationHelper
  DANGEROUS_SCOPES = %w(
    read
    write
    follow
  ).freeze

  def active_nav_class(path)
    current_page?(path) ? 'active' : ''
  end

  def active_link_to(label, path, **options)
    link_to label, path, options.merge(class: active_nav_class(path))
  end

  def show_landing_strip?
    !user_signed_in? && !single_user_mode?
  end

  def open_registrations?
    Setting.open_registrations
  end

  def open_deletion?
    Setting.open_deletion
  end

  def add_rtl_body_class(other_classes)
    other_classes = "#{other_classes} rtl" if locale_direction == 'rtl'
    other_classes
  end

  def locale_direction
    if [:ar, :fa, :he].include?(I18n.locale)
      'rtl'
    else
      'ltr'
    end
  end

  def favicon_path
    env_suffix = Rails.env.production? ? '' : '-dev'
    "/favicon#{env_suffix}.ico"
  end

  def title
    Rails.env.production? ? site_title : "#{site_title} (Dev)"
  end

  def class_for_scope(scope)
    'scope-danger' if DANGEROUS_SCOPES.include?(scope.to_s)
  end

  def can?(action, record)
    return false if record.nil?
    policy(record).public_send("#{action}?")
  end

  def fa_icon(icon, attributes = {})
    class_names = attributes[:class]&.split(' ') || []
    class_names << 'fa'
    class_names += icon.split(' ').map { |cl| "fa-#{cl}" }

    content_tag(:i, nil, attributes.merge(class: class_names.join(' ')))
  end

  def custom_emoji_tag(custom_emoji)
    image_tag(custom_emoji.image.url, class: 'emojione', alt: ":#{custom_emoji.shortcode}:")
  end

  def opengraph(property, content)
    tag(:meta, content: content, property: property)
  end

  def react_component(name, props = {})
    content_tag(:div, nil, data: { component: name.to_s.camelcase, props: Oj.dump(props) })
  end
end
