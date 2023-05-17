# frozen_string_literal: true

module Admin
  class EmergencyRulesController < BaseController
    before_action :set_rule, except: [:index]

    def index
      authorize [:emergency, :rule], :index?

      @rules = Emergency::Rule.all.to_a
    end

    def deactivate
      authorize @rule, :deactivate?
      # TODO: log?
      @rule.deactivate!

      redirect_to admin_emergency_rules_path, notice: I18n.t('admin.emergency_rules.deactivated_msg')
    end

    private

    def set_rule
      @rule = Emergency::Rule.find(params[:id])
    end
  end
end
