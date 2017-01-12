# frozen_string_literal: true

class Setting < RailsSettings::Base
  source Rails.root.join('config/settings.yml')
  namespace Rails.env

  def to_param
    var
  end

  class << self
    def all_as_records
      vars    = thing_scoped
      records = vars.map { |r| [r.var, r] }.to_h

      default_settings.each do |key, default_value|
        next if records.key?(key) || default_value.is_a?(Hash)
        records[key] = Setting.new(var: key, value: default_value)
      end

      records
    end

    private

    def default_settings
      return {} unless RailsSettings::Default.enabled?
      RailsSettings::Default.instance
    end
  end
end
