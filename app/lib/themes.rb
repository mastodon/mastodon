# frozen_string_literal: true

require 'singleton'
require 'yaml'

class Themes
  include Singleton

  def initialize
    result = Hash.new
    Dir.glob(Rails.root.join('app', 'javascript', 'themes', '*', 'theme.yml')) do |path|
      data = YAML.load_file(path)
      name = File.basename(File.dirname(path))
      if data['pack']
        result[name] = data
      end
    end
    @conf = result
  end

  def get(name)
    @conf[name]
  end

  def names
    @conf.keys
  end
end
