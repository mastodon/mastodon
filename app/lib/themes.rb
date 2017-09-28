# frozen_string_literal: true

require 'singleton'
require 'yaml'

class Themes
  include Singleton

  def initialize
    result = Hash.new
    Dir.glob(Rails.root.join('app', 'javascript', 'themes', '*', 'theme.yml')) do |path|
      data = YAML.load_file(path)
      if data['pack'] && data['name']
        result[data['name']] = data
      end
    end
    @conf = result
  end

  def names
    @conf.keys
  end
end
