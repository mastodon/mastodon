# frozen_string_literal: true

module StatusesHelper
  VISIBLITY_ICONS = {
    public: 'globe',
    unlisted: 'lock_open',
    private: 'lock',
    direct: 'alternate_email',
  }.freeze

  def nothing_here(extra_classes = '')
    tag.div(class: ['nothing-here', extra_classes]) do
      t('accounts.nothing_here')
    end
  end

  def status_description(status)
    StatusDescriptionPresenter.new(status).description
  end

  def visibility_icon(status)
    VISIBLITY_ICONS[status.visibility.to_sym]
  end

  def prefers_autoplay?
    ActiveModel::Type::Boolean.new.cast(params[:autoplay]) || current_user&.setting_auto_play_gif
  end

  def render_seo_schema(status)
    json = ActiveModelSerializers::SerializableResource.new(
      status,
      serializer: SEO::SocialMediaPostingSerializer,
      adapter: SEO::Adapter
    ).to_json

    # rubocop:disable Rails/OutputSafety
    content_tag(:script, json_escape(json).html_safe, type: 'application/ld+json')
    # rubocop:enable Rails/OutputSafety
  end
end
