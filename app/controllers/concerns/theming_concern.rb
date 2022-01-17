# frozen_string_literal: true

module ThemingConcern
  extend ActiveSupport::Concern

  def use_pack(pack_name)
    @core = resolve_pack_with_common(Themes.instance.core, pack_name)
    @theme = resolve_pack_with_common(Themes.instance.flavour(current_flavour), pack_name, current_skin)
  end

  private

  def valid_pack_data?(data, pack_name)
    data['pack'].is_a?(Hash) && [String, Hash].any? { |c| data['pack'][pack_name].is_a?(c) }
  end

  def nil_pack(data)
    {
      use_common: true,
      flavour: data['name'],
      pack: nil,
      preload: nil,
      skin: nil,
      supported_locales: data['locales'],
    }
  end

  def pack(data, pack_name, skin)
    pack_data = {
      use_common: true,
      flavour: data['name'],
      pack: pack_name,
      preload: nil,
      skin: nil,
      supported_locales: data['locales'],
    }

    return pack_data unless data['pack'][pack_name].is_a?(Hash)

    pack_data[:use_common] = false if data['pack'][pack_name]['use_common'] == false
    pack_data[:pack] = nil unless data['pack'][pack_name]['filename']

    preloads = data['pack'][pack_name]['preload']
    pack_data[:preload] = [preloads] if preloads.is_a?(String)
    pack_data[:preload] = preloads if preloads.is_a?(Array)

    if skin != 'default' && data['skin'][skin]
      pack_data[:skin] = skin if data['skin'][skin].include?(pack_name)
    else # default skin
      pack_data[:skin] = 'default' if data['pack'][pack_name]['stylesheet']
    end

    pack_data
  end

  def resolve_pack(data, pack_name, skin)
    return pack(data, pack_name, skin) if valid_pack_data?(data, pack_name)
    return if data['name'].blank?

    fallbacks = []
    if data.key?('fallback')
      fallbacks = data['fallback'] if data['fallback'].is_a?(Array)
      fallbacks = [data['fallback']] if data['fallback'].is_a?(String)
    elsif data['name'] != Setting.default_settings['flavour']
      fallbacks = [Setting.default_settings['flavour']]
    end

    fallbacks.each do |fallback|
      return resolve_pack(Themes.instance.flavour(fallback), pack_name) if Themes.instance.flavour(fallback)
    end

    nil
  end

  def resolve_pack_with_common(data, pack_name, skin = 'default')
    result = resolve_pack(data, pack_name, skin) || nil_pack(data)
    result[:common] = resolve_pack(data, 'common', skin) if result.delete(:use_common)
    result
  end
end
