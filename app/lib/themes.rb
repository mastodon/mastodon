# frozen_string_literal: true

require 'singleton'
require 'yaml'

class Themes
  include Singleton

  THEME_COLORS = {
    dark: '#191b22',
    light: '#f3f5f7',
  }.freeze

  def initialize
    @conf = YAML.load_file(Rails.root.join('config', 'themes.yml'))
  end

  def names
    ['system'] + @conf.keys
  end
end
