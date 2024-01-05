# frozen_string_literal: true

# == Schema Information
#
# Table name: settings
#
#  id         :bigint(8)        not null, primary key
#  var        :string           not null
#  value      :text
#  thing_type :string
#  created_at :datetime
#  updated_at :datetime
#  thing_id   :bigint(8)
#

# Vendored from a fork of the `rails-settings-cached` gem that has diverged
# significantly. To refactored inside the `Setting` class.
module RailsSettings
  class Default < ::Hash
    class MissingKey < StandardError; end

    class << self
      def enabled?
        source_path && File.exist?(source_path)
      end

      def source(value = nil)
        @source ||= value
      end

      def source_path
        @source || Rails.root.join('config/app.yml')
      end

      def [](key)
        # foo.bar.dar Nested fetch value
        return instance[key] if instance.key?(key)
        keys = key.to_s.split('.')
        val = instance
        keys.each do |k|
          val = val.fetch(k.to_s, nil)
          break if val.nil?
        end
        val
      end

      def instance
        return @instance if defined? @instance
        @instance = new
        @instance
      end
    end

    def initialize
      content = open(self.class.source_path).read
      hash = content.empty? ? {} : YAML.load(ERB.new(content).result, aliases: true).to_hash
      hash = hash[Rails.env] || {}
      replace hash
    end
  end

  class Base < ActiveRecord::Base
    class SettingNotFound < RuntimeError; end

    self.table_name = table_name_prefix + 'settings'

    after_commit :rewrite_cache, on: %i(create update)
    after_commit :expire_cache, on: %i(destroy)

    # get the value field, YAML decoded
    def value
      YAML.unsafe_load(self[:value]) if self[:value].present?
    end

    # set the value field, YAML encoded
    def value=(new_value)
      self[:value] = new_value.to_yaml
    end

    def rewrite_cache
      Rails.cache.write(cache_key, value)
    end

    def expire_cache
      Rails.cache.delete(cache_key)
    end

    def cache_key
      self.class.cache_key(var)
    end

    class << self
      # get or set a variable with the variable as the called method
      # rubocop:disable Style/MethodMissing
      def method_missing(method, *args)
        # set a value for a variable
        if method_name.end_with?('=')
          var_name = method_name.sub('=', '')
          value = args.first
          self[var_name] = value
        else
          # retrieve a value
          self[method_name]
        end
      end

      # destroy the specified settings record
      def destroy(var_name)
        var_name = var_name.to_s
        obj = object(var_name)
        raise SettingNotFound, "Setting variable \"#{var_name}\" not found" if obj.nil?

        obj.destroy
        true
      end

      def where(sql = nil)
        vars = thing_scoped.where(sql) if sql
        vars
      end

      def merge!(var_name, hash_value)
        raise ArgumentError unless hash_value.is_a?(Hash)

        old_value = self[var_name] || {}
        raise TypeError, "Existing value is not a hash, can't merge!" unless old_value.is_a?(Hash)

        new_value = old_value.merge(hash_value)
        self[var_name] = new_value if new_value != old_value

        new_value
      end

      def object(var_name)
        return nil unless rails_initialized?
        return nil unless table_exists?
        thing_scoped.where(var: var_name.to_s).first
      end

      def thing_scoped
        unscoped.where('thing_type is NULL and thing_id is NULL')
      end

      def source(filename)
        Default.source(filename)
      end

      def rails_initialized?
        Rails.application && Rails.application.initialized?
      end

      def cache_prefix_by_startup
        return @cache_prefix_by_startup if defined? @cache_prefix_by_startup
        return '' unless Default.enabled?
        @cache_prefix_by_startup = Digest::MD5.hexdigest(Default.instance.to_s)
      end

      def cache_prefix(&block)
        @cache_prefix = block
      end

      def cache_key(var_name)
        scope = ['rails_settings_cached', cache_prefix_by_startup]
        scope << @cache_prefix.call if @cache_prefix
        scope << var_name.to_s
        scope.join('/')
      end

      def [](key)
        return get(key) unless rails_initialized?
        val = Rails.cache.fetch(cache_key(key)) do
          get(key)
        end
        val
      end

      # set a setting value by [] notation
      def []=(var_name, value)
        var_name = var_name.to_s

        record = object(var_name) || thing_scoped.new(var: var_name)
        record.value = value
        record.save!

        Rails.cache.write(cache_key(var_name), value)
        value
      end

      private

      def default_settings(starting_with = nil)
        return {} unless Default.enabled?
        return Default.instance if starting_with.nil?
        Default.instance.select { |key, _| key.to_s.start_with?(starting_with) }
      end

      # get a setting value by [] notation
      def get(var_name)
        val = object(var_name)
        return val.value if val
        return Default[var_name] if Default.enabled?
      end
    end
  end
end

class Setting < RailsSettings::Base
  source Rails.root.join('config', 'settings.yml')

  def to_param
    var
  end

  class << self
    def [](key)
      return super(key) unless rails_initialized?

      Rails.cache.fetch(cache_key(key)) do
        db_val = object(key)

        if db_val
          default_value = default_settings[key]

          return default_value.with_indifferent_access.merge!(db_val.value) if default_value.is_a?(Hash)

          db_val.value
        else
          default_settings[key]
        end
      end
    end

    def all_as_records
      vars    = thing_scoped
      records = vars.index_by(&:var)

      default_settings.each do |key, default_value|
        next if records.key?(key) || default_value.is_a?(Hash)

        records[key] = Setting.new(var: key, value: default_value)
      end

      records
    end

    def default_settings
      return {} unless RailsSettings::Default.enabled?

      RailsSettings::Default.instance
    end
  end
end
