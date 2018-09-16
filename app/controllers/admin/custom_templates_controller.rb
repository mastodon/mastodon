# frozen_string_literal: true

module Admin
  class CustomTemplatesController < BaseController
    before_action :set_custom_template, except: [:index, :new, :create]
    before_action :set_filter_params

    def index
      authorize :custom_template, :index?
      @custom_templates = filtered_custom_templates.page(params[:page])
    end

    def new
      authorize :custom_template, :create?
      @custom_template = CustomTemplate.new
    end

    def create
      authorize :custom_template, :create?

      @custom_template = CustomTemplate.new(resource_params)

      if @custom_template.save
        log_action :create, @custom_template
        redirect_to admin_custom_templates_path, notice: I18n.t('admin.custom_templates.created_msg')
      else
        render :new
      end
    end

    def destroy
      authorize @custom_template, :destroy?
      @custom_template.destroy!
      log_action :destroy, @custom_template
      flash[:notice] = I18n.t('admin.custom_templates.destroyed_msg')
      redirect_to admin_custom_templates_path(page: params[:page], **@filter_params)
    end

    def enable
      authorize @custom_template, :enable?
      @custom_template.update!(disabled: false)
      log_action :enable, @custom_template
      flash[:notice] = I18n.t('admin.custom_templates.enabled_msg')
      redirect_to admin_custom_templates_path(page: params[:page], **@filter_params)
    end

    def disable
      authorize @custom_template, :disable?
      @custom_template.update!(disabled: true)
      log_action :disable, @custom_template
      flash[:notice] = I18n.t('admin.custom_templates.disabled_msg')
      redirect_to admin_custom_templates_path(page: params[:page], **@filter_params)
    end

    private

    def set_custom_template
      @custom_template = CustomTemplate.find(params[:id])
    end

    def set_filter_params
      @filter_params = filter_params.to_hash.symbolize_keys
    end

    def resource_params
      params.require(:custom_template).permit(:content)
    end

    def filtered_custom_templates
      CustomTemplateFilter.new(filter_params).results
    end

    def filter_params
      params.permit(
        :content
      )
    end
  end
end

