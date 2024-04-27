# frozen_string_literal: true

module ThemingConcern
  extend ActiveSupport::Concern

  def use_pack(pack_name)
    @theme = resolve_pack(Themes.instance.flavour(current_flavour), pack_name)
  end

  private

  def current_flavour
    [current_user&.setting_flavour, Setting.flavour, 'glitch', 'vanilla'].find { |flavour| Themes.instance.flavours.include?(flavour) }
  end

  def current_skin
    skins = Themes.instance.skins_for(current_flavour)
    [current_user&.setting_skin, Setting.skin, 'default'].find { |skin| skins.include?(skin) }
  end

  def current_theme
    # NOTE: this is slightly different from upstream, as it's a derived value used
    # for the sole purpose of pointing to the appropriate stylesheet pack
    "skins/#{current_flavour}/#{current_skin}"
  end

  def resolve_pack(data, pack_name)
    pack_data = {
      flavour: data['name'],
      pack: nil,
      preload: nil,
      supported_locales: data['locales'],
    }
    return pack_data unless data['pack'].is_a?(Hash) && data['pack'][pack_name].present?

    pack_data[:pack] = pack_name
    return pack_data unless data['pack'][pack_name].is_a?(Hash)

    pack_data[:pack] = nil unless data['pack'][pack_name]['filename']

    preloads = data['pack'][pack_name]['preload']
    pack_data[:preload] = [preloads] if preloads.is_a?(String)
    pack_data[:preload] = preloads if preloads.is_a?(Array)

    pack_data
  end
end
