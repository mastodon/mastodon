# frozen_string_literal: true

require 'singleton'
require 'yaml'

class Themes
  include Singleton

  MASTODON_DARK_THEME_COLOR = '#191b22'
  MASTODON_LIGHT_THEME_COLOR = '#f3f5f7'

  def initialize
    @conf = YAML.load_file(Rails.root.join('config', 'themes.yml'))
  end

  def names
    ['system'] + @conf.keys
  end
end
