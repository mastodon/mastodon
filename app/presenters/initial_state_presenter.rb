# frozen_string_literal: true

class InitialStatePresenter < ActiveModelSerializers::Model
  attributes :settings, :push_subscription, :token,
             :current_account, :admin, :text, :outlets

  def outlets
    YAML.load_file('config/plugins.yml').fetch('outlets', [])
  rescue Errno::ENOENT
    []
  end
end
