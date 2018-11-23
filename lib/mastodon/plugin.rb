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

    class << self
      def use_outlet(path, outlet)
        paths.add NamedPath.new(outlet, relative_path_prefix(path), :outlets)
      end

      def use_routes(&block)
        routes.add block
      end

      def use_extension(const, &block)
        actions.add(proc { const.constantize.class_eval(&block) })
      end

      def use_fabricator(name, &block)
        actions.add(proc { Fabricator(name, &block) }) unless Rails.env.test?
      end

      def initialize!
        # add all folders from app to list of folders to autoload
        folders_in_directory('app') { |folder| folders.add(folder) }

        # add all assets from /assets to list of files to pull into webpacker
        files_in_directory('assets', '{js,scss,jpg,jpeg,png,svg}') { |asset| assets.add(asset) }

        # add all translations from /locales to list of translations
        files_in_directory('locales', 'js') do |path|
          file = path.split('/').last.gsub('.js', '')
          paths.add NamedPath.new(file, relative_path_prefix(path), :locales)
        end
      end

      def disable!
        @@disabled = true
      end
    end
  end
end
