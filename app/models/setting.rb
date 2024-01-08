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

# This file is derived from a fork of the `rails-settings-cached` gem available at
# https://github.com/mastodon/rails-settings-cached/tree/v0.6.6-aliases-true, with
# the original available at:
# https://github.com/huacnlee/rails-settings-cached/tree/0.x

# It is licensed as follows:

# Copyright (c) 2006 Alex Wayne
# Some additional features added 2009 by Georg Ledermann

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOa AND
# NONINFRINGEMENT. IN NO EVENT SaALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class Setting < ApplicationRecord
  class SettingNotFound < RuntimeError; end

  after_commit :rewrite_cache, on: %i(create update)
  after_commit :expire_cache, on: %i(destroy)

  class << self
    # get or set a variable with the variable as the called method
    # rubocop:disable Style/MissingRespondToMissing
    def method_missing(method, *args)
      # set a value for a variable
      if method.end_with?('=')
        var_name = method.to_s.chomp('=')
        value = args.first
        self[var_name] = value
      else
        # retrieve a value
        self[method.to_s]
      end
    end
    # rubocop:enable Style/MissingRespondToMissing

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

    def rails_initialized?
      Rails.application&.initialized?
    end

    def cache_prefix_by_startup
      return @cache_prefix_by_startup if defined? @cache_prefix_by_startup

      @cache_prefix_by_startup = Digest::MD5.hexdigest(default_settings.to_s)
    end

    def cache_key(var_name)
      "rails_settings_cached/#{cache_prefix_by_startup}/#{var_name}"
    end

    def [](key)
      return get(key) unless rails_initialized?

      Rails.cache.fetch(cache_key(key)) do
        db_val = object(key)
        default_value = default_settings[key]

        if db_val
          return default_value.with_indifferent_access.merge!(db_val.value) if default_value.is_a?(Hash)

          db_val.value
        else
          default_value
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

    # set a setting value by [] notation
    def []=(var_name, value)
      var_name = var_name.to_s

      record = object(var_name) || thing_scoped.new(var: var_name)
      record.value = value
      record.save!
    end

    def default_settings
      return @default_settings if defined?(@default_settings)

      content = Rails.root.join('config', 'settings.yml').read
      hash = content.empty? ? {} : YAML.safe_load(ERB.new(content).result, aliases: true).to_hash
      @default_settings = hash[Rails.env] || {}
    end

    private

    # get a setting value by [] notation
    def get(var_name)
      val = object(var_name)
      return val.value if val

      default_settings[var_name]
    end
  end

  # get the value field, YAML decoded
  def value
    YAML.safe_load(self[:value], permitted_classes: [ActiveSupport::HashWithIndifferentAccess, Symbol]) if self[:value].present?
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

  def to_param
    var
  end
end
