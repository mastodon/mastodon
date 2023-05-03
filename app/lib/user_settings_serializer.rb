# frozen_string_literal: true

class UserSettingsSerializer
  def self.load(value)
    json = begin
      if value.blank?
        {}
      else
        Oj.load(value, symbol_keys: true)
      end
    end

    UserSettings.new(json)
  end

  def self.dump(value)
    Oj.dump(value.as_json)
  end
end
