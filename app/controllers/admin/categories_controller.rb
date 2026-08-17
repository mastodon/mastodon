# frozen_string_literal: true

module Admin
  class CategoriesController < BaseController
    before_action :set_category, except: [:index, :new, :create]

    def index
      authorize :category, :index?

      @categories = Category.ordered.page(params[:page])
    end

    def new
      authorize :category, :create?

      @category = Category.new
    end

    def edit
      authorize @category, :update?
    end

    def create
      authorize :category, :create?

      @category = Category.new(resource_params)

      if @category.save
        log_action :create, @category
        redirect_to admin_categories_path
      else
        render :new, status: 422
      end
    end

    def update
      authorize @category, :update?

      if @category.update(resource_params)
        log_action :update, @category
        redirect_to admin_categories_path
      else
        render :edit, status: 422
      end
    end

    def destroy
      authorize @category, :destroy?

      @category.destroy!
      log_action :destroy, @category
      redirect_to admin_categories_path
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def resource_params
      params.expect(category: [:name, :description, :mandatory_for_readers])
    end
  end
end
