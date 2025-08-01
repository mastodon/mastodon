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
end
