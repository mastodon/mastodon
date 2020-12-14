# frozen_string_literal: true

module WebAppControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_body_classes
    before_action :set_referrer_policy_header
  end

  def set_body_classes
    @body_classes = 'app-body'
  end

  def set_referrer_policy_header
    response.headers['Referrer-Policy'] = 'origin'
  end
end
