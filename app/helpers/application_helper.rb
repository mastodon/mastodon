# frozen_string_literal: true

module ApplicationHelper
  DANGEROUS_SCOPES = %w(
    read
    write
    follow
  ).freeze

  def active_nav_class(*paths)
    paths.any? { |path| current_page?(path) } ? 'active' : ''
  end

  def active_link_to(label, path, **options)
    link_to label, path, options.merge(class: active_nav_class(path))
  end

  def show_landing_strip?
    !user_signed_in? && !single_user_mode?
  end

  def open_registrations?
    Setting.registrations_mode == 'open'
  end

  def approved_registrations?
    Setting.registrations_mode == 'approved'
  end

  def closed_registrations?
    Setting.registrations_mode == 'none'
  end

  def available_sign_up_path
    if closed_registrations?
      'https://joinmastodon.org/#getting-started'
    else
      new_user_registration_path
    end
  end

  def open_deletion?
    Setting.open_deletion
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

  def custom_emoji_tag(custom_emoji, animate = true)
    if animate
      image_tag(custom_emoji.image.url, class: 'emojione', alt: ":#{custom_emoji.shortcode}:")
    else
      image_tag(custom_emoji.image.url(:static), class: 'emojione custom-emoji', alt: ":#{custom_emoji.shortcode}", 'data-original' => full_asset_url(custom_emoji.image.url), 'data-static' => full_asset_url(custom_emoji.image.url(:static)))
    end
  end

  def opengraph(property, content)
    tag(:meta, content: content, property: property)
  end

  def react_component(name, props = {}, &block)
    if block.nil?
      content_tag(:div, nil, data: { component: name.to_s.camelcase, props: Oj.dump(props) })
    else
      content_tag(:div, data: { component: name.to_s.camelcase, props: Oj.dump(props) }, &block)
    end
  end

  def body_classes
    output = (@body_classes || '').split(' ')
    output << "theme-#{current_theme.parameterize}"
    output << 'system-font' if current_account&.user&.setting_system_font_ui
    output << (current_account&.user&.setting_reduce_motion ? 'reduce-motion' : 'no-reduce-motion')
    output << 'rtl' if locale_direction == 'rtl'
    output.reject(&:blank?).join(' ')
  end

  def cdn_host
    Rails.configuration.action_controller.asset_host
  end

  def cdn_host?
    cdn_host.present?
  end

  def storage_host
    "https://#{ENV['S3_ALIAS_HOST'].presence || ENV['S3_CLOUDFRONT_HOST']}"
  end

  def storage_host?
    ENV['S3_ALIAS_HOST'].present? || ENV['S3_CLOUDFRONT_HOST'].present?
  end

  def quote_wrap(text, line_width: 80, break_sequence: "\n")
    text = word_wrap(text, line_width: line_width - 2, break_sequence: break_sequence)
    text.split("\n").map { |line| '> ' + line }.join("\n")
  end

  def render_initial_state
    state_params = {
      settings: {
        known_fediverse: Setting.show_known_fediverse_at_about_page,
      },

      text: [params[:title], params[:text], params[:url]].compact.join(' '),
    }

    permit_visibilities = %w(public unlisted private direct)
    default_privacy     = current_account&.user&.setting_default_privacy
    permit_visibilities.shift(permit_visibilities.index(default_privacy) + 1) if default_privacy.present?
    state_params[:visibility] = params[:visibility] if permit_visibilities.include? params[:visibility]

    if user_signed_in?
      state_params[:settings]          = state_params[:settings].merge(Web::Setting.find_by(user: current_user)&.data || {})
      state_params[:push_subscription] = current_account.user.web_push_subscription(current_session)
      state_params[:current_account]   = current_account
      state_params[:token]             = current_session.token
      state_params[:admin]             = Account.find_local(Setting.site_contact_username.strip.gsub(/\A@/, ''))
    end

    json = ActiveModelSerializers::SerializableResource.new(InitialStatePresenter.new(state_params), serializer: InitialStateSerializer).to_json
    content_tag(:script, json_escape(json).html_safe, id: 'initial-state', type: 'application/json')
  end
end
