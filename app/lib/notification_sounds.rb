# frozen_string_literal: true

require 'singleton'
require 'yaml'

class NotificationSounds
  include Singleton

  def initialize
    @conf = YAML.load_file(Rails.root.join('config', 'sounds.yml'))
  end

  def names
    @conf.keys
  end

  def by_name(name)
    @conf[name]
  end
end
