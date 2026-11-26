# frozen_string_literal: true

class REST::Admin::ServerCheckSerializer < ActiveModel::Serializer
  include RoutingHelper
  include Admin::ServerChecksHelper

  attributes :key, :status, :ignored, :severity, :category, :checked_at, :title, :explanation, :setup_url

  def title
    admin_server_check_title(object)
  end

  def explanation
    admin_server_check_lead(object)
  end

  def setup_url
    admin_server_check_setup_url(object)
  end

  private

  def t(...)
    I18n.t(...)
  end
end
