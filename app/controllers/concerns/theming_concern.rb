# frozen_string_literal: true

module ThemingConcern
  extend ActiveSupport::Concern

  private

  def current_flavour
    @current_flavour ||= [current_user&.setting_flavour, Setting.flavour, 'glitch', 'vanilla'].find { |flavour| Themes.instance.flavours.include?(flavour) }
  end

  def current_skin
    @current_skin ||= begin
      skins = Themes.instance.skins_for(current_flavour)
      [current_user&.setting_skin, Setting.skin, 'system', 'default'].find { |skin| skins.include?(skin) }
    end
  end

  def current_theme
    # NOTE: this is slightly different from upstream, as it's a derived value used
    # for the sole purpose of pointing to the appropriate stylesheet pack
    [current_flavour, current_skin]
  end
end
