# frozen_string_literal: true

module ThemingConcern
  extend ActiveSupport::Concern

  def use_pack(pack_name)
    @theme = resolve_pack_with_common(Themes.instance.flavour(current_flavour), pack_name, current_skin)
  end

  private

  def current_flavour
    [current_user&.setting_flavour, Setting.flavour, 'glitch', 'vanilla'].find { |flavour| Themes.instance.flavours.include?(flavour) }
  end

  def current_skin
    skins = Themes.instance.skins_for(current_flavour)
    [current_user&.setting_skin, Setting.skin, 'default'].find { |skin| skins.include?(skin) }
  end

  def valid_pack_data?(data, pack_name)
    data['pack'].is_a?(Hash) && data['pack'][pack_name].present?
  end

  def nil_pack(data)
    {
      flavour: data['name'],
      pack: nil,
      preload: nil,
      skin: nil,
      supported_locales: data['locales'],
    }
  end

  def pack(data, pack_name, skin)
    pack_data = {
      flavour: data['name'],
      pack: pack_name,
      preload: nil,
      skin: nil,
      supported_locales: data['locales'],
    }

    return pack_data unless data['pack'][pack_name].is_a?(Hash)

    pack_data[:pack] = nil unless data['pack'][pack_name]['filename']

    preloads = data['pack'][pack_name]['preload']
    pack_data[:preload] = [preloads] if preloads.is_a?(String)
    pack_data[:preload] = preloads if preloads.is_a?(Array)

    if skin != 'default' && data['skin'][skin]
      pack_data[:skin] = skin if data['skin'][skin].include?(pack_name)
    elsif data['pack'][pack_name]['stylesheet']
      pack_data[:skin] = 'default'
    end

    pack_data
  end

  def resolve_pack(data, pack_name, skin)
    pack(data, pack_name, skin) if valid_pack_data?(data, pack_name)
  end

  def resolve_pack_with_common(data, pack_name, skin = 'default')
    result = resolve_pack(data, pack_name, skin) || nil_pack(data)
    result[:common] = resolve_pack(data, 'common', skin)
    result
  end
end
