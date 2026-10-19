# frozen_string_literal: true

class Themes
  include Singleton

  THEME_COLORS = {
    dark: '#181820',
    light: '#ffffff',
  }.freeze

  def initialize
    @flavours = {}

    Rails.root.glob('app/javascript/flavours/*/theme.yml') do |pathname|
      data = YAML.safe_load_file(pathname)
      next unless data['pack_directory']

      dir = pathname.dirname
      name = dir.basename.to_s
      locales = []
      screenshots = []

      if data['locales']
        Dir.glob(File.join(dir, data['locales'], '*.{js,json}')) do |locale|
          locale_name = File.basename(locale, File.extname(locale))
          locales.push(locale_name) unless /defaultMessages|whitelist|index/.match?(locale_name)
        end
      end

      if data['screenshot']
        if data['screenshot'].is_a? Array
          screenshots = data['screenshot']
        else
          screenshots.push(data['screenshot'])
        end
      end

      data['name'] = name
      data['locales'] = locales
      data['screenshot'] = screenshots
      data['skins'] = {}
      @flavours[name] = data
    end

    Rails.root.glob('app/javascript/skins/*/*') do |pathname|
      ext = pathname.extname.to_s
      flavour_name = pathname.dirname.basename.to_s

      if pathname.directory?
        skin = pathname.basename.to_s if pathname.glob('{common,index,application}.{css,scss}').any?
        next unless skin

        metadata = load_theme_metadata(pathname.join('theme.yml'), skin)
      elsif /^\.s?css$/i.match?(ext)
        skin = pathname.basename(ext).to_s
        metadata = load_theme_metadata(pathname.sub_ext('.yml'), skin)
      end

      next unless skin

      @flavours[flavour_name]['skins'][skin] = metadata
    end
  end

  def flavour(name)
    @flavours[name]
  end

  def flavours
    @flavours.keys
  end

  def skins_for(name)
    skins = @flavours[name]['skins'].keys
    skins.include?('default') && skins.include?('mastodon-light') ? ['system'] + skins : skins
  end

  def available_theme_colors(theme)
    flavour, skin = theme

    return [] if @flavours.dig(flavour, 'skins', skin, 'colors').blank?

    @flavours.dig(flavour, 'skins', skin, 'colors')
  end

  private

  def load_theme_metadata(pathname, skin)
    begin
      data = YAML.safe_load_file(pathname)
    rescue Errno::ENOENT
      return { colors: [] }
    end

    data[skin]
  end
end
