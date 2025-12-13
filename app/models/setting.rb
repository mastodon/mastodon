# frozen_string_literal: true

# == Schema Information
#
# Table name: settings
#
#  id         :bigint(8)        not null, primary key
#  var        :string           not null
#  value      :text
#  created_at :datetime
#  updated_at :datetime
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
  after_commit :rewrite_cache, on: %i(create update)
  after_commit :expire_cache, on: %i(destroy)

  self.ignored_columns += %w(
    thing_id
    thing_type
  )

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

    def cache_prefix_by_startup
      @cache_prefix_by_startup ||= Digest::MD5.hexdigest(default_settings.to_s)
    end

    def cache_key(var_name)
      "rails_settings_cached/#{cache_prefix_by_startup}/#{var_name}"
    end

    def [](key)
      Rails.cache.fetch(cache_key(key)) do
        db_val = find_by(var: key)
        db_val ? db_val.value : default_settings[key]
      end
    end

    # set a setting value by [] notation
    def []=(var_name, value)
      record = find_or_initialize_by(var: var_name.to_s)
      record.value = value
      record.save!
    end

    def default_settings
      return @default_settings if defined?(@default_settings)

      content = Rails.root.join('config', 'settings.yml').read
      hash = content.empty? ? {} : YAML.safe_load(ERB.new(content).result, aliases: true).to_hash
      @default_settings = (hash[Rails.env] || {}).freeze
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
