# frozen_string_literal: true

require 'singleton'
require 'yaml'

class Themes
  include Singleton

  def initialize
    core = YAML.load_file(Rails.root.join('app', 'javascript', 'core', 'theme.yml'))
    core['pack'] = {} unless core['pack']

    result = {}
    Rails.root.glob('app/javascript/flavours/*/theme.yml') do |pathname|
      data = YAML.load_file(pathname)
      next unless data['pack']

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
      data['skin'] = { 'default' => [] }
      result[name] = data
    end

    Rails.root.glob('app/javascript/skins/*/*') do |pathname|
      ext = pathname.extname.to_s
      skin = pathname.basename.to_s
      name = pathname.dirname.basename.to_s
      next unless result[name]

      if pathname.directory?
        pack = []
        pathname.glob('*.{css,scss}') do |sheet|
          pack.push(sheet.basename(sheet.extname).to_s)
        end
      elsif /^\.s?css$/i.match?(ext)
        skin = pathname.basename(ext).to_s
        pack = ['common']
      end

      result[name]['skin'][skin] = pack if skin != 'default'
    end

    @core = core
    @conf = result
  end

  attr_reader :core

  def flavour(name)
    @conf[name]
  end

  def flavours
    @conf.keys
  end

  def skins_for(name)
    @conf[name]['skin'].keys
  end

  def flavours_and_skins
    flavours.map do |flavour|
      [flavour, skins_for(flavour).map { |skin| [flavour, skin] }]
    end
  end
end
