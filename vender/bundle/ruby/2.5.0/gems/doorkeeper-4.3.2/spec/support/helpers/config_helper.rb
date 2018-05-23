module ConfigHelper
  def config_is_set(setting, value = nil, &block)
    setting_ivar = "@#{setting}"
    value = block_given? ? block : value
    Doorkeeper.configuration.instance_variable_set(setting_ivar, value)
  end
end

RSpec.configuration.send :include, ConfigHelper
