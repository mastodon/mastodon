# frozen_string_literal: true
require_relative './plugin_utils'

module Mastodon
  class Plugin
    extend PluginUtils
    NamedPath = Struct.new(:name, :path, :type)

    @@paths   = Set.new
    @@assets  = Set.new
    @@folders = Set.new
    @@routes  = Set.new
    @@actions = Set.new
    @@disabled = false

    cattr_reader :paths
    cattr_reader :assets
    cattr_reader :folders
    cattr_reader :routes
    cattr_reader :actions
    cattr_reader :disabled

    def self.use_classes
      folders_in_directory('app') { |folder| @@folders.add(folder) }
    end

    def self.use_assets
      files_in_directory('assets', '{js,scss,jpg,jpeg,png,svg}') { |asset| @@assets.add(asset) }
    end

    def self.use_translations(path = 'locales')
      files_in_directory('locales', 'js') do |path|
        file = path.split('/').last.gsub('.js', '')
        @@paths.add NamedPath.new(file, relative_path_prefix(path), :locales)
      end
    end

    def self.use_outlet(path, outlet)
      @@paths.add NamedPath.new(outlet, relative_path_prefix(path), :outlets)
    end

    def self.use_routes(&block)
      @@routes.add(block)
    end

    def self.extend_class(const, &block)
      @@actions.add(proc { const.constantize.class_eval(&block) })
    end

    def self.use_fabricator(name, &block)
      @@actions.add(proc { Fabricator(name, &block) }) unless Rails.env.test?
    end

    def self.disable!
      @@disabled = true
    end
  end
end
