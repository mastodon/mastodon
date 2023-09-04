class MigrateOpenRegistrationsSetting < ActiveRecord::Migration[5.2]
  def up
    open_registrations = Setting.find_by(var: 'open_registrations')
    return if open_registrations.nil? || open_registrations.value
    setting = Setting.where(var: 'registrations_mode').first_or_initialize(var: 'registrations_mode')
    setting.update(value: 'none')
  end

  def down
    registrations_mode = Setting.find_by(var: 'registrations_mode')
    return if registrations_mode.nil?
    setting = Setting.where(var: 'open_registrations').first_or_initialize(var: 'open_registrations')
    setting.update(value: registrations_mode.value == 'open')
  end
end
