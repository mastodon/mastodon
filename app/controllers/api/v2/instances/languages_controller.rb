# frozen_string_literal: true

class Api::V2::Instances::LanguagesController < Api::V1::InstancesController
  def index
    render json: LanguagesHelper::SUPPORTED_LOCALES, status: 200
  end
end
