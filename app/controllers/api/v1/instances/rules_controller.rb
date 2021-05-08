# frozen_string_literal: true

class Api::V1::Instances::RulesController < Api::BaseController
  skip_before_action :require_authenticated_user!, unless: :whitelist_mode?

  before_action :set_rules

  def index
    render json: @rules, each_serializer: REST::RuleSerializer
  end

  private

  def set_rules
    @rules = Rule.ordered
  end
end
