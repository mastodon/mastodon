class FanTarget < ActiveYaml::Base
  include ActiveHash::Associations
  set_root_path "config/master/fan_target"
  set_filename ENV.fetch('FAN_TARGET', 'npb')
  has_many :accounts

  def icon_path
    "fan-target/#{ENV.fetch('FAN_TARGET', 'npb')}/#{self.key}-icon.png"
  end
end
