# frozen_string_literal: true

module Admin
  class RulesController < BaseController
    before_action :set_rule, except: [:index, :new, :create]

    def index
      authorize :rule, :index?

      @rules = Rule.ordered.includes(:translations)
    end

    def new
      authorize :rule, :create?
      @rule = Rule.new
    end

    def edit
      authorize @rule, :update?

      missing_languages = RuleTranslation.languages - @rule.translations.pluck(:language)
      missing_languages.each { |lang| @rule.translations.build(language: lang) }
    end

    def create
      authorize :rule, :create?

      @rule = Rule.new(resource_params)

      if @rule.save
        redirect_to admin_rules_path
      else
        render :new
      end
    end

    def update
      authorize @rule, :update?

      if @rule.update(resource_params)
        redirect_to admin_rules_path
      else
        render :edit
      end
    end

    def destroy
      authorize @rule, :destroy?

      @rule.discard

      redirect_to admin_rules_path
    end

    def move_up
      authorize @rule, :update?

      @rule.move!(-1)

      redirect_to admin_rules_path
    end

    def move_down
      authorize @rule, :update?

      @rule.move!(+1)

      redirect_to admin_rules_path
    end

    private

    def set_rule
      @rule = Rule.find(params[:id])
    end

    def resource_params
      params
        .expect(rule: [:text, :hint, :priority, translations_attributes: [[:id, :language, :text, :hint, :_destroy]]])
    end
  end
end
