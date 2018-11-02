# frozen_string_literal: true

class Api::V1::PluginsController < Api::BaseController

  respond_to :json

  def outlets
    render json: config_outlets
  end

  private

  def config_outlets
    YAML.load_file('config/plugins.yml').fetch('outlets', [])
  rescue Errno::ENOENT
    []
  end

end
