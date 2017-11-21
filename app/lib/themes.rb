# frozen_string_literal: true

require 'singleton'
require 'yaml'

class Themes
  include Singleton

  def initialize

    core = YAML.load_file(Rails.root.join('app', 'javascript', 'core', 'theme.yml'))
    core['pack'] = Hash.new unless core['pack']

    result = Hash.new
    Dir.glob(Rails.root.join('app', 'javascript', 'themes', '*', 'theme.yml')) do |path|
      data = YAML.load_file(path)
      name = File.basename(File.dirname(path))
      if data['pack']
        data['name'] = name
        result[name] = data
      end
    end

    @core = core
    @conf = result

  end

  def core
    @core
  end

  def get(name)
    @conf[name]
  end

  def names
    @conf.keys
  end
end
