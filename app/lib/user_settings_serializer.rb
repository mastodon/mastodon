# frozen_string_literal: true

class UserSettingsSerializer
  def self.load(value)
    json = begin
      if value.blank?
        {}
      else
        JSON.parse(value, symbolize_names: true)
      end
    end

    UserSettings.new(json)
  end

  def self.dump(value)
    JSON.dump(value.as_json)
  end
end
