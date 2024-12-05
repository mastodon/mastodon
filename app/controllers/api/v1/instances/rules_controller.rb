# frozen_string_literal: true

class Api::V1::Instances::RulesController < Api::V1::Instances::BaseController
  skip_around_action :set_locale

  before_action :set_rules

  # Override `current_user` to avoid reading session cookies unless in limited federation mode
  def current_user
    super if limited_federation_mode?
  end

  def index
    cache_even_if_authenticated!
    render json: @rules, each_serializer: REST::RuleSerializer
  end

  private

  def set_rules
    @rules = Rule.ordered
  end
end
