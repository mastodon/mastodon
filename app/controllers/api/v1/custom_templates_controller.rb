# frozen_string_literal: true

class Api::V1::CustomTemplatesController < Api::BaseController
  respond_to :json

  def index
    render json: CustomTemplate.where(disabled: false), each_serializer: REST::CustomTemplateSerializer
  end
end
